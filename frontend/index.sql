-- this script is for the /index endpoint which creates the login/registration page

create or replace function api.index() 
returns "text/html" as $$
select $html$
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PG Messenger | Gateway</title>
    <script src="https://unpkg.com/htmx.org@1.9.10"></script>
    
    <!-- ROCK SOLID REDIRECT: Intercept immediately before page load -->
    <script>
        if (localStorage.getItem('pg_jwt')) {
            window.location.replace('/rpc/app');
        }
    </script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;800&display=swap');
        
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
            max-width: 360px; 
            box-shadow: 0 24px 48px rgba(0,0,0,0.7);
            border: 1px solid var(--border);
        }
        h2 { 
            text-align: center; 
            margin-top: 0; 
            margin-bottom: 2rem; 
            font-weight: 800; 
            letter-spacing: -0.5px; 
            font-size: 1.5rem;
        }
        h2 span { color: var(--primary); }
        
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
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        input:focus { 
            outline: none; 
            border-color: var(--primary); 
            box-shadow: 0 0 0 3px rgba(88, 166, 255, 0.1);
        }
        
        button { 
            width: 100%; 
            padding: 0.85rem; 
            background: var(--primary); 
            color: #ffffff; 
            border: none; 
            border-radius: 6px; 
            font-size: 0.95rem;
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
            font-weight: 500;
            font-size: 0.9rem;
            transition: color 0.2s, border-bottom 0.2s;
            border-bottom: 2px solid transparent;
        }
        .tab.active { color: var(--text); border-bottom: 2px solid var(--primary); }
        
        .form-section { display: none; animation: fadeIn 0.3s ease-in-out; }
        .form-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }
        
        #console { 
            margin-top: 1.5rem; 
            padding: 1rem; 
            background: #010409; 
            font-family: 'Courier New', Courier, monospace; 
            border-radius: 6px; 
            min-height: 20px; 
            font-size: 0.8rem;
            border: 1px solid var(--border);
            color: var(--text-muted);
            text-align: center;
        }
        .msg-success { color: var(--success); font-weight: 600; }
        .msg-error { color: var(--error); font-weight: 600; }
    </style>
</head>
<body hx-headers='{"Accept": "application/json"}'>

<div class="container">
    <h2>PG <span>Messenger</span></h2>
    
    <div class="tabs">
        <div class="tab active" id="tab-login" onclick="switchTab('login')">Sign In</div>
        <div class="tab" id="tab-register" onclick="switchTab('register')">Create Account</div>
    </div>

    <form id="login-form" class="form-section active" 
          hx-post="/rpc/authenticate" 
          hx-swap="none">
        <input type="email" name="_email" placeholder="Email Address" required>
        <input type="password" name="_password" placeholder="Password" required>
        <button type="submit">Secure Login</button>
    </form>

    <form id="register-form" class="form-section" 
          hx-post="/rpc/register_account" 
          hx-swap="none">
        <input type="email" name="_email" placeholder="Email Address" required>
        <input type="password" name="_password" placeholder="Password" required>
        <input type="text" name="_display_name" placeholder="Display Name" required>
        <button type="submit">Initialize Account</button>
    </form>

    <div id="console">Awaiting authentication...</div>
</div>

<script>
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
        
        const consoleEl = document.getElementById('console');
        consoleEl.innerHTML = 'Awaiting authentication...';
        consoleEl.style.color = 'var(--text-muted)';
    }

    document.body.addEventListener('htmx:afterRequest', function(evt) {
        const xhr = evt.detail.xhr;
        const consoleEl = document.getElementById('console');
        
        try {
            const response = JSON.parse(xhr.response);
            
            if (xhr.status >= 200 && xhr.status < 300) {
                if (evt.detail.requestConfig.path === '/rpc/authenticate') {
                    // SILENT AUTHENTICATION & REDIRECT
                    consoleEl.innerHTML = `<span class="msg-success">Handshake confirmed. Redirecting...</span>`;
                    localStorage.setItem('pg_jwt', response.token); 
                    
                    // Give the user a brief visual confirmation before zooming them into the app
                    setTimeout(() => {
                        window.location.replace('/rpc/app');
                    }, 600);
                    
                } else {
                    consoleEl.innerHTML = `<span class="msg-success">Profile provisioned successfully.</span>`;
                    evt.detail.elt.reset(); 
                    setTimeout(() => switchTab('login'), 1500); 
                }
            } else {
                consoleEl.innerHTML = `<span class="msg-error">${response.message || 'Access Denied'}</span>`;
            }
        } catch(e) {
            consoleEl.innerHTML = `<span class="msg-error">Network anomaly detected</span>`;
        }
    });
</script>
</body>
</html>
$html$;
$$ language sql;