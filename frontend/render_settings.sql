-- function to render the settings dashboard

create or replace function api.render_settings()
returns text
language plpgsql as $$
declare
    _user_id uuid;
    _display_name text;
    _avatar_url text;
    _email text;
    html_output text;
begin
    -- Force raw HTML output
    perform set_config('response.headers', '[{"Content-Type": "text/html"}]', true);

    _user_id := api.auth_profile_id();

    -- Fetch current profile
    select display_name, avatar_url into _display_name, _avatar_url
    from api.profile where id = _user_id;

    -- Fetch current email
    select email into _email from api.my_account;

    html_output := $css$
    <style>
        .settings-container, .settings-container * {
            box-sizing: border-box;
        }
        .settings-container {
            padding: 3rem 4rem;
            height: 100%;
            width: 100%;
            overflow-y: auto;
            animation: fadeIn 0.4s ease;
        }
        .settings-header {
            margin-bottom: 2rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            padding-bottom: 1rem;
        }
        .settings-header h2 {
            font-size: 2.2rem;
            color: white;
            margin: 0;
            font-weight: 700;
        }
        .settings-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2.5rem;
            align-items: flex-start;
        }
        .settings-card {
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 2.5rem;
            box-shadow: 0 8px 32px rgba(0,0,0,0.2);
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        .settings-card h3 {
            color: white;
            margin-top: 0;
            margin-bottom: 0.5rem;
            font-size: 1.4rem;
            display: flex;
            align-items: center;
            gap: 0.8rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            padding-bottom: 1rem;
        }
        .settings-form {
            display: flex;
            flex-direction: column;
            gap: 1.2rem;
        }
        .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        .form-group label {
            color: #94a3b8;
            font-size: 0.95rem;
            font-weight: 500;
        }
        .settings-input {
            width: 100%;
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 0.8rem 1.2rem;
            color: white;
            outline: none;
            font-family: 'Outfit', sans-serif;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        .settings-input:focus {
            border-color: rgba(79, 172, 254, 0.5);
            background: rgba(0, 0, 0, 0.5);
            box-shadow: 0 0 0 4px rgba(79, 172, 254, 0.1);
        }
        .settings-btn {
            background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 0.9rem 2rem;
            font-weight: 700;
            cursor: pointer;
            font-family: 'Outfit', sans-serif;
            font-size: 1.05rem;
            transition: all 0.2s ease;
            box-shadow: 0 4px 15px rgba(79, 172, 254, 0.3);
            width: 100%;
            margin-top: 0.5rem;
        }
        .settings-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(79, 172, 254, 0.4);
        }
        .settings-btn:active {
            transform: translateY(1px);
        }
        
        /* Special dangerous button styling */
        .danger-btn {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            box-shadow: 0 4px 15px rgba(239, 68, 68, 0.2);
        }
        .danger-btn:hover {
            box-shadow: 0 6px 20px rgba(239, 68, 68, 0.35);
        }

        .settings-divider {
            height: 1px;
            background: rgba(255,255,255,0.05);
            margin: 1rem 0;
            width: 100%;
        }
    </style>
    $css$;

    html_output := html_output || format('
    <div class="settings-container">
        <div class="settings-header">
            <h2>Settings</h2>
        </div>
        
        <div class="settings-grid">
            <!-- Profile Details -->
            <div class="settings-card">
                <h3>👤 Profile Details</h3>
                <form class="settings-form"
                      hx-ext="json-enc" 
                      hx-patch="/profile?id=eq.%s" 
                      hx-swap="none"
                      hx-on::after-request="if(event.detail.successful) showToast(''Profile details updated successfully!'')">
                    
                    <div class="form-group">
                        <label>Display Name</label>
                        <input type="text" name="display_name" class="settings-input" value="%s" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Avatar URL</label>
                        <input type="url" name="avatar_url" class="settings-input" value="%s" placeholder="https://example.com/avatar.jpg">
                    </div>
                    
                    <button type="submit" class="settings-btn">Save Profile</button>
                </form>
            </div>

            <!-- Account Details -->
            <div class="settings-card">
                <h3>🔐 Account Details</h3>
                
                <!-- Email Update -->
                <form class="settings-form"
                      hx-ext="json-enc" 
                      hx-patch="/my_account?email=eq.%s" 
                      hx-swap="none"
                      hx-on::after-request="if(event.detail.successful) { showToast(''Email updated successfully!''); setTimeout(() => window.location.reload(), 1000); }">
                    
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" class="settings-input" value="%s" required>
                    </div>
                    
                    <button type="submit" class="settings-btn">Update Email</button>
                </form>

                <div class="settings-divider"></div>

                <!-- Password Update -->
                <form class="settings-form"
                      hx-ext="json-enc" 
                      hx-post="/rpc/change_password" 
                      hx-swap="none"
                      hx-on::after-request="if(event.detail.successful) { showToast(''Password changed! Please log in again.''); setTimeout(performLogout, 1500); }">
                    
                    <div class="form-group">
                        <label>New Password</label>
                        <input type="password" name="_new_password" class="settings-input" placeholder="Enter new password" required minlength="6">
                    </div>
                    
                    <button type="submit" class="settings-btn danger-btn">Change Password</button>
                </form>
            </div>
        </div>
    </div>
    ',
    _user_id::text,
    replace(replace(coalesce(_display_name, ''), '&', '&amp;'), '"', '&quot;'),
    replace(replace(coalesce(_avatar_url, ''), '&', '&amp;'), '"', '&quot;'),
    _email,
    _email
    );

    return html_output;
end;
$$;
