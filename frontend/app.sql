-- this script is for the /app endpoint which creates the application page

create or replace function api.app() 
returns "text/html" as $$
select $html$
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PG Messenger | Dashboard</title>
    <script src="https://unpkg.com/htmx.org@1.9.10"></script>
    <script src="https://unpkg.com/htmx.org@1.9.10/dist/ext/json-enc.js"></script>
    <script>
        const token = localStorage.getItem('pg_jwt');
        if (!token) window.location.replace('/rpc/index');

        document.addEventListener('htmx:configRequest', function(evt) {
            evt.detail.headers['Authorization'] = 'Bearer ' + token;
        });

        // THE FIX: The JSON Unwrapper
        document.addEventListener('htmx:beforeSwap', function(evt) {
            try {
                // Parse the response. If it's a JSON-wrapped string, this removes the \n and \" escaping
                const parsed = JSON.parse(evt.detail.xhr.response);
                if (typeof parsed === 'string') {
                    // Hand the clean, raw HTML back to HTMX for rendering
                    evt.detail.serverResponse = parsed;
                }
            } catch (e) {
                // If it fails to parse, it means it is already raw HTML, so we do nothing.
            }
        });

        function performLogout() {
            localStorage.removeItem('pg_jwt');
            window.location.replace('/rpc/index');
        }
    </script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap');
        
        :root { 
            --bg-dark: #0B0F19; 
            --surface: rgba(15, 23, 42, 0.6); 
            --surface-light: rgba(30, 41, 59, 0.7);
            --primary-gradient: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
            --primary: #4facfe;
            --text: #ffffff; 
            --text-muted: #94a3b8;
            --border: rgba(255, 255, 255, 0.08);
            --danger: #ef4444;
        }
        
        body { 
            font-family: 'Outfit', sans-serif; 
            background-color: var(--bg-dark); 
            background-image: 
                radial-gradient(circle at 100% 0%, rgba(79, 172, 254, 0.1), transparent 50%),
                radial-gradient(circle at 0% 100%, rgba(0, 242, 254, 0.1), transparent 50%);
            color: var(--text); 
            margin: 0; 
            height: 100vh; 
            display: flex; 
            overflow: hidden;
        }

        /* Pane 1: The Left Navigation Rail */
        .nav-rail {
            width: 76px;
            background: rgba(15, 23, 42, 0.8);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 2rem 0;
            z-index: 20;
            box-shadow: 5px 0 25px rgba(0,0,0,0.2);
        }

        .nav-icon {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            background: transparent;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 1.5rem;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            color: var(--text-muted);
            font-size: 1.2rem;
            position: relative;
        }

        .nav-icon:hover { 
            background: var(--surface-light); 
            color: var(--primary); 
            transform: translateY(-2px);
        }
        .nav-icon.active { 
            background: var(--primary-gradient); 
            color: white; 
            box-shadow: 0 4px 15px rgba(79, 172, 254, 0.4);
        }
        
        .spacer { flex-grow: 1; }

        /* Pane 2: The Inbox Column */
        .inbox-column {
            width: 340px;
            background: rgba(15, 23, 42, 0.5);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            z-index: 10;
        }

        .inbox-header {
            padding: 1.8rem 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(255,255,255,0.02);
        }
        
        .inbox-header h3 { 
            margin: 0; 
            font-size: 1.25rem; 
            font-weight: 700; 
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .new-chat-btn {
            background: var(--primary-gradient);
            border: none;
            color: white;
            cursor: pointer;
            width: 32px;
            height: 32px;
            border-radius: 8px;
            font-size: 1.2rem;
            display: flex;
            justify-content: center;
            align-items: center;
            transition: all 0.2s ease;
            box-shadow: 0 2px 10px rgba(79, 172, 254, 0.3);
        }
        .new-chat-btn:hover { transform: translateY(-2px) scale(1.05); box-shadow: 0 4px 12px rgba(79, 172, 254, 0.4); }
        .new-chat-btn:active { transform: scale(0.95); }
        
        .icon-btn {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            color: white;
            cursor: pointer;
            width: 32px;
            height: 32px;
            border-radius: 8px;
            font-size: 1.1rem;
            display: flex;
            justify-content: center;
            align-items: center;
            transition: all 0.2s ease;
        }
        .icon-btn:hover { background: rgba(255,255,255,0.1); transform: translateY(-2px); }

        .inbox-content {
            flex-grow: 1;
            overflow-y: auto;
            padding: 0;
        }
        
        .inbox-content::-webkit-scrollbar { width: 6px; }
        .inbox-content::-webkit-scrollbar-track { background: transparent; }
        .inbox-content::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 10px; }

        /* Pane 3: The Main Chat Area */
        .chat-area {
            flex-grow: 1;
            background: transparent;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
        }

        .empty-state {
            text-align: center;
            color: var(--text-muted);
            animation: fadeIn 1s ease;
        }
        
        .empty-state-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
            opacity: 0.8;
            filter: drop-shadow(0 0 20px rgba(79, 172, 254, 0.4));
        }

        .empty-state h2 { 
            color: var(--text); 
            margin-bottom: 0.5rem; 
            font-weight: 700;
            font-size: 1.8rem;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Toast Notifications */
        #toast-container {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            z-index: 1000;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        .toast {
            background: rgba(15, 23, 42, 0.95);
            border: 1px solid #4facfe;
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
            animation: slideInRight 0.3s ease forwards, fadeOut 0.3s ease 2.7s forwards;
            font-weight: 500;
        }
        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(100%); }
            to { opacity: 1; transform: translateX(0); }
        }
        @keyframes fadeOut {
            from { opacity: 1; }
            to { opacity: 0; }
        }
    </style>
    <script>
        function showToast(message) {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            toast.className = 'toast';
            toast.textContent = message;
            container.appendChild(toast);
            setTimeout(() => toast.remove(), 3000);
        }
    </script>
</head>
<body>

    <!-- Pane 1: Navigation -->
    <div class="nav-rail">
        <div class="nav-icon active" title="Messages" onClick="window.location.reload()">💬</div>
        <div class="nav-icon" title="Settings" hx-get="/rpc/render_settings" hx-target="#chat-container" hx-swap="innerHTML">⚙️</div>
        <div class="spacer"></div>
        <div class="nav-icon" title="Logout" onclick="performLogout()" style="color: var(--danger);">⏏️</div>
    </div>

    <!-- Pane 2: Inbox -->
    <div class="inbox-column">
        <div class="inbox-header">
            <h3 id="inbox-title">Messages</h3>
            <div style="display: flex; gap: 0.5rem; align-items: center;">
                <button class="icon-btn" id="toggle-archive-btn" title="Archived Chats" 
                        hx-get="/rpc/render_archive" hx-target="#inbox-container" 
                        onclick="document.getElementById('inbox-title').innerText = 'Archived'; this.style.display='none'; document.getElementById('toggle-inbox-btn').style.display='flex';">🗄️</button>
                <button class="icon-btn" id="toggle-inbox-btn" title="Active Chats" style="display: none;" 
                        hx-get="/rpc/render_inbox" hx-target="#inbox-container" 
                        onclick="document.getElementById('inbox-title').innerText = 'Messages'; this.style.display='none'; document.getElementById('toggle-archive-btn').style.display='flex';">📥</button>
                <button class="new-chat-btn" title="Start New Chat"
                        hx-get="/rpc/render_user_directory"
                        hx-target="#chat-container"
                        hx-swap="innerHTML">+</button>
            </div>
        </div>
        
        <div class="inbox-content" 
             id="inbox-container"
             hx-get="/rpc/render_inbox" 
             hx-trigger="load">
            
            <div style="text-align: center; color: var(--text-muted); margin-top: 3rem; font-size: 0.95rem;">
                <div style="display:inline-block; width:20px; height:20px; border:2px solid var(--primary); border-radius:50%; border-top-color:transparent; animation:spin 1s linear infinite; margin-bottom:1rem;"></div><br>
                Loading encrypted inbox...
            </div>
            <style>@keyframes spin { to { transform: rotate(360deg); } }</style>
            
        </div>
    </div>

    <!-- Pane 3: Chat Interface -->
    <div class="chat-area" id="chat-container">
        <div class="empty-state">
            <div class="empty-state-icon">✨</div>
            <h2>PG Messenger</h2>
            <p>Select a conversation from the left to start end-to-end messaging.</p>
        </div>
    </div>
    <!-- Toast Container -->
    <div id="toast-container"></div>

    <!-- Realtime WebSocket Integration (Upgraded) -->
    <script type="module">
        import { RealtimeClient } from 'https://cdn.jsdelivr.net/npm/@supabase/realtime-js@2.10.2/+esm';

        const jwt = localStorage.getItem('pg_jwt');
        if (!jwt) return;

        const client = new RealtimeClient('ws://localhost:4000/socket', {
            params: { apikey: jwt } 
        });
        client.connect();

        const channel = client.channel('realtime:public:chat_events');

        // 1. Listen to ALL events on the Message table (* means INSERT, UPDATE, and DELETE)
        channel.on('postgres_changes', { event: '*', schema: 'api', table: 'message' }, payload => {
            const activeConvInput = document.querySelector('input[name="conversation_id"]');
            // Safe check: handle whether it's an INSERT/UPDATE (has payload.new) or DELETE (has payload.old)
            const activeConvId = payload.new ? payload.new.conversation_id : payload.old.conversation_id;
            const msgId = payload.new ? payload.new.id : payload.old.id;
            const isActiveChat = activeConvInput && activeConvInput.value === activeConvId;

            // Handle INSERT (New Messages)
            if (payload.eventType === 'INSERT') {
                if (isActiveChat) {
                    if (!document.getElementById('msg-' + msgId)) {
                        htmx.ajax('POST', '/rpc/render_message_bubble', {
                            target: '#message-list',
                            swap: 'beforeend',
                            values: { _msg_id: msgId }
                        }).then(() => {
                            const msgList = document.getElementById('message-list');
                            if(msgList) msgList.scrollTop = msgList.scrollHeight;
                        });
                    }
                } else {
                    showToast('New message received! 💬');
                }
            }

            // Handle UPDATE (Edited Messages)
            if (payload.eventType === 'UPDATE') {
                if (isActiveChat && document.getElementById('msg-' + msgId)) {
                    // Ask Postgres to render the updated HTML and swap it over the old bubble
                    htmx.ajax('POST', '/rpc/render_message_bubble', {
                        target: '#msg-' + msgId,
                        swap: 'outerHTML',
                        values: { _msg_id: msgId }
                    });
                }
            }

            // Handle DELETE (Deleted Messages)
            if (payload.eventType === 'DELETE') {
                if (isActiveChat) {
                    const msgElement = document.getElementById('msg-' + msgId);
                    if (msgElement) {
                        // Smooth fade out before removing from DOM
                        msgElement.style.transition = "opacity 0.3s ease, transform 0.3s ease";
                        msgElement.style.opacity = "0";
                        msgElement.style.transform = "scale(0.95)";
                        setTimeout(() => msgElement.remove(), 300);
                    }
                }
            }

            // INBOX SYNC: No matter what happened to the message, refresh the inbox 
            // so the latest message snippet and timestamps stay accurate!
            htmx.trigger('#inbox-container', 'load');
        });

        // 2. Listen to Conversation updates (e.g., someone changed the group name)
        channel.on('postgres_changes', { event: 'UPDATE', schema: 'api', table: 'conversation' }, payload => {
            // Silently fetch the updated inbox view
            htmx.trigger('#inbox-container', 'load');
            
            // If they are currently looking at the renamed chat, optionally reload the chat header
            const activeConvInput = document.querySelector('input[name="conversation_id"]');
            if (activeConvInput && activeConvInput.value === payload.new.id) {
                 htmx.ajax('POST', '/rpc/render_chat', {
                     target: '#chat-container',
                     values: { _c_id: payload.new.id }
                 });
            }
        });

        channel.subscribe();
    </script>

</body>
</html>
$html$;
$$ language sql;