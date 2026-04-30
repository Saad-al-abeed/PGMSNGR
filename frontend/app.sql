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
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;800&display=swap');
        
        :root { 
            --bg-dark: #010409; 
            --surface: #0d1117; 
            --surface-light: #161b22;
            --primary: #58a6ff; 
            --text: #c9d1d9; 
            --text-muted: #8b949e;
            --border: #30363d;
        }
        
        body { 
            font-family: 'Inter', sans-serif; 
            background: var(--bg-dark); 
            color: var(--text); 
            margin: 0; 
            height: 100vh; 
            display: flex; 
            overflow: hidden;
        }

        /* Pane 1: The Left Navigation Rail */
        .nav-rail {
            width: 70px;
            background: var(--surface);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 1.5rem 0;
            z-index: 10;
        }

        .nav-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            background: var(--surface-light);
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 1rem;
            cursor: pointer;
            border: 1px solid var(--border);
            transition: border-color 0.2s, color 0.2s;
            color: var(--text-muted);
            font-weight: 600;
            font-size: 0.8rem;
        }

        .nav-icon:hover { border-color: var(--primary); color: var(--primary); }
        .nav-icon.active { background: var(--primary); color: white; border-color: var(--primary); }
        
        .spacer { flex-grow: 1; }

        /* Pane 2: The Inbox Column */
        .inbox-column {
            width: 320px;
            background: var(--surface);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            z-index: 5;
        }

        .inbox-header {
            padding: 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .inbox-header h3 { margin: 0; font-size: 1.1rem; font-weight: 600; }
        
        .new-chat-btn {
            background: none;
            border: none;
            color: var(--primary);
            cursor: pointer;
            font-size: 1.5rem;
            line-height: 1;
            padding: 0;
            transition: transform 0.1s;
        }
        .new-chat-btn:active { transform: scale(0.9); }

        .inbox-content {
            flex-grow: 1;
            overflow-y: auto;
            padding: 1rem;
        }

        /* Pane 3: The Main Chat Area */
        .chat-area {
            flex-grow: 1;
            background: var(--bg-dark);
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
        }

        .empty-state {
            text-align: center;
            color: var(--text-muted);
        }
        
        .empty-state h2 { color: var(--text); margin-bottom: 0.5rem; }
    </style>
</head>
<body>

    <!-- Pane 1: Navigation -->
    <div class="nav-rail">
        <div class="nav-icon active" title="Messages">💬</div>
        <div class="nav-icon" title="Settings" style="cursor: not-allowed; opacity: 0.5;">⚙️</div>
        <div class="spacer"></div>
        <div class="nav-icon" title="Logout" onclick="performLogout()" style="color: #f85149; border-color: #f8514944;">⏏️</div>
    </div>

    <!-- Pane 2: Inbox -->
    <div class="inbox-column">
        <div class="inbox-header">
            <h3>Messages</h3>
            <button class="new-chat-btn" title="New Chat">+</button>
        </div>
        
        <div class="inbox-content" 
             id="inbox-container"
             hx-get="/rpc/render_inbox" 
             hx-trigger="load">
            
            <div style="text-align: center; color: var(--text-muted); margin-top: 2rem; font-size: 0.9rem;">
                Loading encrypted inbox...
            </div>
            
        </div>
    </div>

    <!-- Pane 3: Chat Interface -->
    <div class="chat-area" id="chat-container">
        <div class="empty-state">
            <h2>PG Messenger</h2>
            <p>Select a conversation from the left to start end-to-end messaging.</p>
        </div>
    </div>

</body>
</html>
$html$;
$$ language sql;