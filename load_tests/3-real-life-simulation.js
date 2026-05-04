import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    // Simulating 20 active, completely distinct users going through the flow simultaneously 
    vus: 20,
    duration: '1m',
};

const BASE_URL = 'http://localhost:3000';

// ----------------------------------------------------------------------------
// 1. SETUP FUNCTION
// ----------------------------------------------------------------------------
// We create a "Target Bot" user. Every virtual user will create a chat 
// and send messages to this single target bot.
export function setup() {
    const botEmail = `bot_${Math.random().toString(36).substring(2, 10)}@test.com`;
    
    const regRes = http.post(`${BASE_URL}/rpc/register_account`, JSON.stringify({
        _email: botEmail,
        _password: 'botpassword',
        _display_name: 'Target Bot'
    }), { headers: { 'Content-Type': 'application/json', 'Prefer': 'return=representation' } });
    
    // Extract the bot's profile_id so VUs know who to message
    let botId = '';
    try {
        const body = regRes.json();
        botId = Array.isArray(body) ? body[0].id : body.id;
    } catch (e) {
        console.error("Failed to setup Bot:", regRes.body);
    }
    
    return { targetProfileId: botId };
}

// ----------------------------------------------------------------------------
// 2. DEFAULT FUNCTION (Simulated User Journey)
// ----------------------------------------------------------------------------
export default function (data) {
    const email = `user_${__VU}_${__ITER}@test.com`;
    const password = 'password';
    const baseHeaders = { 'Content-Type': 'application/json' };

    // STEP 1: Register Account
    const regRes = http.post(`${BASE_URL}/rpc/register_account`, JSON.stringify({
        _email: email, _password: password, _display_name: `User ${__VU}`
    }), { headers: baseHeaders });
    
    check(regRes, { 'Registered successfully': (r) => r.status === 200 || r.status === 201 });

    // STEP 2: Authenticate (Testing your token_version protocol)
    const authRes = http.post(`${BASE_URL}/rpc/authenticate`, JSON.stringify({
        _email: email, _password: password
    }), { headers: baseHeaders });
    
    check(authRes, { 'Logged in successfully': (r) => r.status === 200 });

    let token = '';
    try {
        const body = authRes.json();
        token = Array.isArray(body) ? body[0].token : body.token;
    } catch (e) { return; } // Exit iteration if auth failed

    const authHeaders = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
    };

    sleep(1); // User taking time to load UI

    // STEP 3: View Inbox (Testing the api.inbox view & RLS)
    const inboxRes = http.get(`${BASE_URL}/inbox`, { headers: authHeaders });
    check(inboxRes, { 'Inbox loaded': (r) => r.status === 200 });

    sleep(1); // User deciding who to message

    // STEP 4: Create a Chat (Testing triggers & block checks)
    // Uses the target bot ID created in the setup function
    const createChatRes = http.post(`${BASE_URL}/rpc/create_chat`, JSON.stringify({
        target_profile_id: data.targetProfileId
    }), { headers: authHeaders });

    check(createChatRes, { 'Chat created': (r) => r.status === 200 });

    let conversationId = '';
    try {
        // PostgREST RPC returns the result of the function
        // In your case, it returns the conversation UUID
        const chatBody = createChatRes.json();
        // Adjust extraction logic based on exactly how PostgREST wraps scalar function returns
        conversationId = Array.isArray(chatBody) ? chatBody[0] : (chatBody.id || chatBody); 
    } catch (e) {
        console.error("Could not parse conversation ID", createChatRes.body);
        return;
    }

    sleep(1); // User typing a message...

    // STEP 5: Send a Message (Testing api.message inserts & RLS)
    if (conversationId) {
        const msgRes = http.post(`${BASE_URL}/message`, JSON.stringify({
            conversation_id: conversationId,
            content: `Hola Virtual User ${__VU}!`
        }), { headers: authHeaders });

        check(msgRes, { 'Message sent (201) or (204)': (r) => (r.status === 201 || r.status === 204) });
    }
}