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
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap');
        
        :root { 
            --bg-base: #0B0F19; 
            --surface: rgba(22, 27, 34, 0.6); 
            --primary-gradient: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
            --primary-hover: linear-gradient(135deg, #00e0eb 0%, #3f9be6 100%);
            --text: #ffffff; 
            --text-muted: #94a3b8;
            --error: #ef4444;
            --success: #10b981;
            --border: rgba(255, 255, 255, 0.08);
        }
        
        body { 
            font-family: 'Outfit', sans-serif; 
            background-color: var(--bg-base);
            background-image: 
                radial-gradient(circle at 15% 50%, rgba(79, 172, 254, 0.15), transparent 25%),
                radial-gradient(circle at 85% 30%, rgba(0, 242, 254, 0.15), transparent 25%);
            background-attachment: fixed;
            color: var(--text); 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0; 
            overflow: hidden;
        }

        .backdrop-glow {
            position: absolute;
            width: 400px;
            height: 400px;
            background: var(--primary-gradient);
            filter: blur(120px);
            opacity: 0.15;
            z-index: 0;
            border-radius: 50%;
            animation: pulse 8s infinite alternate ease-in-out;
        }

        @keyframes pulse {
            0% { transform: scale(1) translate(0, 0); opacity: 0.15; }
            100% { transform: scale(1.1) translate(20px, -20px); opacity: 0.25; }
        }

        .container { 
            background: var(--surface); 
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            padding: 3rem; 
            border-radius: 20px; 
            width: 100%; 
            max-width: 380px; 
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5), inset 0 1px 1px rgba(255, 255, 255, 0.1);
            border: 1px solid var(--border);
            z-index: 1;
            position: relative;
        }
        
        h2 { 
            text-align: center; 
            margin-top: 0; 
            margin-bottom: 2.5rem; 
            font-weight: 800; 
            letter-spacing: -0.5px; 
            font-size: 1.8rem;
        }
        h2 span { 
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            color: transparent;
        }
        
        .input-group {
            position: relative;
            margin-bottom: 1.25rem;
        }

        input { 
            width: 100%; 
            padding: 1rem 1.2rem; 
            background: rgba(0, 0, 0, 0.3); 
            border: 1px solid var(--border); 
            color: white; 
            border-radius: 12px; 
            box-sizing: border-box; 
            font-size: 1rem;
            font-family: 'Outfit', sans-serif;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        input::placeholder { color: transparent; }
        
        input:focus { 
            outline: none; 
            border-color: rgba(79, 172, 254, 0.5); 
            box-shadow: 0 0 0 4px rgba(79, 172, 254, 0.1);
            background: rgba(0, 0, 0, 0.5);
        }

        .floating-label {
            position: absolute;
            left: 1.2rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            pointer-events: none;
            transition: all 0.2s ease;
            font-size: 1rem;
        }

        input:focus ~ .floating-label,
        input:not(:placeholder-shown) ~ .floating-label {
            top: 0;
            transform: translateY(-50%) scale(0.85);
            background: var(--bg-base);
            padding: 0 0.4rem;
            color: #4facfe;
            border-radius: 4px;
        }
        
        button { 
            width: 100%; 
            padding: 1rem; 
            background: var(--primary-gradient); 
            color: #ffffff; 
            border: none; 
            border-radius: 12px; 
            font-size: 1.05rem;
            font-family: 'Outfit', sans-serif;
            font-weight: 700; 
            cursor: pointer; 
            transition: all 0.2s ease; 
            box-shadow: 0 4px 15px rgba(79, 172, 254, 0.3);
            margin-top: 0.5rem;
        }
        button:hover { 
            background: var(--primary-hover);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(79, 172, 254, 0.4);
        }
        button:active { transform: translateY(1px); }
        
        .tabs { 
            display: flex; 
            margin-bottom: 2.5rem; 
            background: rgba(0, 0, 0, 0.2);
            border-radius: 10px;
            padding: 0.3rem;
        }
        .tab { 
            flex: 1; 
            text-align: center; 
            padding: 0.75rem; 
            cursor: pointer; 
            color: var(--text-muted); 
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            border-radius: 8px;
        }
        .tab.active { 
            color: var(--text); 
            background: rgba(255, 255, 255, 0.1); 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .form-section { display: none; animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1); }
        .form-section.active { display: block; }
        
        @keyframes slideUp { 
            from { opacity: 0; transform: translateY(10px); } 
            to { opacity: 1; transform: translateY(0); } 
        }
        
        #console { 
            margin-top: 2rem; 
            padding: 1rem; 
            background: rgba(0, 0, 0, 0.3); 
            font-family: 'Consolas', monospace; 
            border-radius: 10px; 
            min-height: 24px; 
            font-size: 0.85rem;
            border: 1px solid var(--border);
            color: var(--text-muted);
            text-align: center;
            backdrop-filter: blur(5px);
        }
        .msg-success { color: var(--success); font-weight: 600; text-shadow: 0 0 10px rgba(16, 185, 129, 0.3); }
        .msg-error { color: var(--error); font-weight: 600; text-shadow: 0 0 10px rgba(239, 68, 68, 0.3); }
    </style>
</head>
<body hx-headers='{"Accept": "application/json"}'>

<div class="backdrop-glow"></div>

<div class="container">
    <h2>PG <span>Messenger</span></h2>
    
    <div class="tabs">
        <div class="tab active" id="tab-login" onclick="switchTab('login')">Sign In</div>
        <div class="tab" id="tab-register" onclick="switchTab('register')">Create Account</div>
    </div>

    <form id="login-form" class="form-section active" 
          hx-post="/rpc/authenticate" 
          hx-swap="none">
        <div class="input-group">
            <input type="email" name="_email" id="login-email" placeholder=" " required>
            <label class="floating-label" for="login-email">Email Address</label>
        </div>
        <div class="input-group">
            <input type="password" name="_password" id="login-password" placeholder=" " required>
            <label class="floating-label" for="login-password">Password</label>
        </div>
        <button type="submit">Secure Login</button>
    </form>

    <form id="register-form" class="form-section" 
          hx-post="/rpc/register_account" 
          hx-swap="none">
        <div class="input-group">
            <input type="email" name="_email" id="reg-email" placeholder=" " required>
            <label class="floating-label" for="reg-email">Email Address</label>
        </div>
        <div class="input-group">
            <input type="password" name="_password" id="reg-password" placeholder=" " required>
            <label class="floating-label" for="reg-password">Password</label>
        </div>
        <div class="input-group">
            <input type="text" name="_display_name" id="reg-name" placeholder=" " required>
            <label class="floating-label" for="reg-name">Display Name</label>
        </div>
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
                    consoleEl.innerHTML = `<span class="msg-success">Handshake confirmed. Redirecting...</span>`;
                    localStorage.setItem('pg_jwt', response.token); 
                    
                    setTimeout(() => {
                        document.body.style.opacity = '0';
                        document.body.style.transition = 'opacity 0.5s ease';
                        setTimeout(() => window.location.replace('/rpc/app'), 500);
                    }, 400);
                    
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