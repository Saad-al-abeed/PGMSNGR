import http from 'k6/http';
import { check, sleep } from 'k6';

// ----------------------------------------------------------------------------
// 1. CONFIGURATION: Ramping Virtual Users
// ----------------------------------------------------------------------------
export const options = {
    stages: [
        { duration: '30s', target: 50 },  // Ramp up to 50 users over 30 seconds
        { duration: '1m', target: 110 },  // Ramp up to 110 users and hold for 1 min
        { duration: '30s', target: 10 },   // Ramp down to 10 users
    ],
};

const BASE_URL = 'http://localhost:3000';

// ----------------------------------------------------------------------------
// 2. SETUP FUNCTION
// ----------------------------------------------------------------------------
export function setup() {
    const randomSuffix = Math.random().toString(36).substring(2, 10);
    const email = `load_${randomSuffix}@test.com`;
    const password = 'password';

    http.post(`${BASE_URL}/rpc/register_account`, JSON.stringify({
        _email: email, _password: password, _display_name: 'Load Tester'
    }), { headers: { 'Content-Type': 'application/json' } });

    const authRes = http.post(`${BASE_URL}/rpc/authenticate`, JSON.stringify({
        _email: email, _password: password
    }), { headers: { 'Content-Type': 'application/json' } });

    let token = '';
    try {
        const body = authRes.json();
        token = Array.isArray(body) ? body[0].token : body.token;
    } catch (e) {
        console.error("Auth failed:", authRes.body);
    }

    return { token: token };
}

// ----------------------------------------------------------------------------
// 3. DEFAULT FUNCTION
// ----------------------------------------------------------------------------
export default function (data) {
    const params = {
        headers: {
            'Authorization': `Bearer ${data.token}`,
            'Accept': 'application/json',
        },
    };

    // Simulate a user checking their inbox, then checking their archives
    const responses = http.batch([
        ['GET', `${BASE_URL}/inbox`, null, params],
        ['GET', `${BASE_URL}/archive`, null, params]
    ]);

    check(responses[0], { 'inbox status 200': (r) => r.status === 200 });
    check(responses[1], { 'archive status 200': (r) => r.status === 200 });

    // Small pause to simulate human reading time between page loads
    sleep(1);
}