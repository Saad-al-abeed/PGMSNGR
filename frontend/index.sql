-- this script is for the /index endpoint which creates the login/registration page

create or replace function api.index() 
returns "text/html" as $$
select $html$
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PG Messenger</title>
    <script src="https://unpkg.com/htmx.org@1.9.10"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap');
        
        :root { 
            --bg: #0d1117; 
            --surface: #161b22; 
            --primary: #58a6ff; 
            --primary-hover: #3182ce;
            --text: #c9d1d9; 
            --text-muted: #8b949e;
            --error: #f85149;
            --success: #3fb950;
            --border: #30363d;
        }
        body { 
            font-family: 'Inter', sans-serif; 
            background: var(--bg); 
            color: var(--text); 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0; 
            background-image: radial-gradient(circle at top, #1f242c, transparent 60%);
        }
        .container { 
            background: var(--surface); 
            padding: 2.5rem; 
            border-radius: 12px; 
            width: 100%; 
            max-width: 380px; 
            box-shadow: 0 16px 32px rgba(0,0,0,0.5);
            border: 1px solid var(--border);
        }
        h2 { text-align: center; margin-top: 0; margin-bottom: 1.5rem; font-weight: 800; letter-spacing: -0.5px; }
        
        input { 
            width: 100%; 
            padding: 0.85rem 1rem; 
            margin-bottom: 1.2rem; 
            background: #010409; 
            border: 1px solid var(--border); 
            color: white; 
            border-radius: 6px; 
            box-sizing: border-box; 
            font-size: 0.95rem;
            transition: border-color 0.2s;
        }
        input:focus { outline: none; border-color: var(--primary); }
        
        button { 
            width: 100%; 
            padding: 0.85rem; 
            background: var(--primary); 
            color: #ffffff; 
            border: none; 
            border-radius: 6px; 
            font-size: 1rem;
            font-weight: 600; 
            cursor: pointer; 
            transition: background-color 0.2s, transform 0.1s; 
        }
        button:hover { background: var(--primary-hover); }
        button:active { transform: scale(0.98); }
        
        .tabs { display: flex; margin-bottom: 2rem; border-bottom: 1px solid var(--border); }
        .tab { 
            flex: 1; 
            text-align: center; 
            padding: 0.75rem; 
            cursor: pointer; 
            color: var(--text-muted); 
            font-weight: 600;
            transition: color 0.2s, border-bottom 0.2s;
            border-bottom: 2px solid transparent;
        }
        .tab.active { color: var(--primary); border-bottom: 2px solid var(--primary); }
        
        .form-section { display: none; animation: fadeIn 0.3s ease-in-out; }
        .form-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }
        
        #console { 
            margin-top: 2rem; 
            padding: 1.2rem; 
            background: #010409; 
            font-family: 'Courier New', Courier, monospace; 
            border-radius: 6px; 
            min-height: 40px; 
            word-wrap: break-word; 
            font-size: 0.85rem;
            border: 1px solid var(--border);
            color: var(--text-muted);
        }
        .msg-success { color: var(--success); font-weight: bold; }
        .msg-error { color: var(--error); font-weight: bold; }
        .token-box { font-size: 0.75rem; margin-top: 10px; color: var(--text); opacity: 0.7; word-break: break-all; }
    </style>
</head>
<body hx-headers='{"Accept": "application/json"}'>

<div class="container">
    <h2>PG Messenger</h2>
    
    <div class="tabs">
        <div class="tab active" id="tab-login" onclick="switchTab('login')">Login</div>
        <div class="tab" id="tab-register" onclick="switchTab('register')">Register</div>
    </div>

    <form id="login-form" class="form-section active" 
          hx-post="/rpc/authenticate" 
          hx-swap="none">
        <input type="email" name="_email" placeholder="Email Address" required>
        <input type="password" name="_password" placeholder="Password" required>
        <button type="submit">Log In</button>
    </form>

    <form id="register-form" class="form-section" 
          hx-post="/rpc/register_account" 
          hx-swap="none">
        <input type="email" name="_email" placeholder="Email Address" required>
        <input type="password" name="_password" placeholder="Password" required>
        <input type="text" name="_display_name" placeholder="Display Name" required>
        <button type="submit">Create Account</button>
    </form>

    <div id="console">System ready. Waiting for input...</div>
</div>

<script>
    // UI Tab Switching Logic
    function switchTab(tab) {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.form-section').forEach(f => f.classList.remove('active'));
        
        if (tab === 'login') {
            document.getElementById('tab-login').classList.add('active');
            document.getElementById('login-form').classList.add('active');
        } else {
            document.getElementById('tab-register').classList.add('active');
            document.getElementById('register-form').classList.add('active');
        }
        
        // Reset console on tab switch
        const consoleEl = document.getElementById('console');
        consoleEl.innerHTML = 'System ready. Waiting for input...';
        consoleEl.style.color = 'var(--text-muted)';
    }

    // HTMX Response Interceptor
    document.body.addEventListener('htmx:afterRequest', function(evt) {
        const xhr = evt.detail.xhr;
        const consoleEl = document.getElementById('console');
        
        try {
            // Parse the JSON response from PostgREST
            const response = JSON.parse(xhr.response);
            
            // If HTTP Status is 200 OK (or 201 Created)
            if (xhr.status >= 200 && xhr.status < 300) {
                
                if (evt.detail.requestConfig.path === '/rpc/authenticate') {
                    // Login Success
                    consoleEl.innerHTML = `<span class="msg-success">✓ Authentication successful</span><div class="token-box">JWT: ${response.token}</div>`;
                    // Save JWT to browser for future API calls
                    localStorage.setItem('pg_jwt', response.token); 
                    
                } else {
                    // Registration Success
                    consoleEl.innerHTML = `<span class="msg-success">✓ User created successfully</span>`;
                    evt.detail.elt.reset(); // Clear the form inputs
                    
                    // Auto-switch to login tab after 2 seconds
                    setTimeout(() => switchTab('login'), 2000); 
                }
                
            } else {
                // If HTTP Status is 4xx or 5xx (Database Error)
                consoleEl.innerHTML = `<span class="msg-error">✗ ${response.message || 'Action failed'}</span>`;
            }
        } catch(e) {
            // Fallback for extreme network errors
            consoleEl.innerHTML = `<span class="msg-error">✗ Unexpected network error</span>`;
        }
    });
</script>
</body>
</html>
$html$;
$$ language sql;