--
-- PostgreSQL database dump
--

\restrict GbdC27QJI970kGs39aef8faUVKock4NfbhwOfkQDl22d68yP7cqOJ97IdBsjf22

-- Dumped from database version 18.3 (Debian 18.3-1+b1)
-- Dumped by pg_dump version 18.3 (Debian 18.3-1+b1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: api; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO postgres;

--
-- Name: private; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA private;


ALTER SCHEMA private OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: jwt_token; Type: TYPE; Schema: api; Owner: postgres
--

CREATE TYPE api.jwt_token AS (
	token text
);


ALTER TYPE api.jwt_token OWNER TO postgres;

--
-- Name: text/html; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public."text/html" AS text;


ALTER DOMAIN public."text/html" OWNER TO postgres;

--
-- Name: app(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.app() RETURNS public."text/html"
    LANGUAGE sql
    AS $_$
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
                <button class="new-chat-btn" title="New Chat">+</button>
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

</body>
</html>
$html$;
$_$;


ALTER FUNCTION api.app() OWNER TO postgres;

--
-- Name: auth_profile_id(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.auth_profile_id() RETURNS uuid
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
declare
    _jwt_id uuid := nullif(current_setting('request.jwt.claims', true)::json->>'profile_id', '')::uuid;
    _jwt_version int := (current_setting('request.jwt.claims', true)::json->>'token_version')::int;
    _db_version int;
begin
    if _jwt_id is null or _jwt_version is null then 
        return null;
    end if;

    select token_version into _db_version from private.account where id = _jwt_id;

    if _db_version = _jwt_version then 
        return _jwt_id;
    else 
        return null;
    end if;
end;
$$;


ALTER FUNCTION api.auth_profile_id() OWNER TO postgres;

--
-- Name: authenticate(text, text); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.authenticate(_email text, _password text) RETURNS api.jwt_token
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
	account_data private.account;
	jwt api.jwt_token;
begin
	select * into account_data from private.account
	where email = _email;

	if account_data.email is null then raise exception 'invalid email or password';
	end if;

	if account_data.password_hash != crypt(_password, account_data.password_hash)
	then raise exception 'invalid email or password'; end if;

	jwt.token := sign(json_build_object(
		'role', account_data.role,
		'profile_id', account_data.id,
		'token_version', account_data.token_version,
		'exp', extract(epoch from now() + interval '7 days')), 'thisstringissoverysecretextrachars');

	return jwt;
end;
$$;


ALTER FUNCTION api.authenticate(_email text, _password text) OWNER TO postgres;

--
-- Name: change_password(text); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.change_password(_new_password text) RETURNS void
    LANGUAGE sql SECURITY DEFINER
    AS $$
	update private.account set
	password_hash = crypt(_new_password, gen_salt('bf')),
	token_version = token_version + 1
	where id = api.auth_profile_id(); -- manual security because RLS aint gonna work here
$$;


ALTER FUNCTION api.change_password(_new_password text) OWNER TO postgres;

--
-- Name: create_chat(uuid); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.create_chat(target_profile_id uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
    existing_conv_id uuid;
    new_conv_id uuid;
	block_exists boolean;
begin
    -- Prevent users from trying to DM themselves
    if target_profile_id = api.auth_profile_id() then
        raise exception 'You cannot create a direct message with yourself.';
    end if;

	-- check for block
	select exists (
        select 1 from api.block
        where (blocker_id = api.auth_profile_id() and blocked_id = target_profile_id)
           or (blocker_id = target_profile_id and blocked_id = api.auth_profile_id())
    ) into block_exists;

    -- If a block exists, throw error
    if block_exists then
        raise exception 'Cannot create a direct message with this user.';
    end if;

    -- Does a DM already exist between these two users?
    select c.id into existing_conv_id
    from api.conversation c
    join api.participant p1 on c.id = p1.conversation_id
    join api.participant p2 on c.id = p2.conversation_id
    where c.type = 'direct'
      and p1.profile_id = api.auth_profile_id()
      and p2.profile_id = target_profile_id
    limit 1;

    -- If it exists, activate it and return the old ID.
    if existing_conv_id is not null then
        update api.participant
        set status = 'active'
        where conversation_id = existing_conv_id
          and profile_id = api.auth_profile_id();
          
        return existing_conv_id;
    end if;

    -- If it doesn't exist, build a brand new room.
    insert into api.conversation (type) values ('direct')
    returning id into new_conv_id;

    insert into api.participant (conversation_id, profile_id, role) values
    (new_conv_id, api.auth_profile_id(), 'member');

    insert into api.participant (conversation_id, profile_id, role) values
    (new_conv_id, target_profile_id, 'member');

    return new_conv_id;
end;
$$;


ALTER FUNCTION api.create_chat(target_profile_id uuid) OWNER TO postgres;

--
-- Name: create_group_chat(text, uuid[]); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.create_group_chat(_name text, target_profile_ids uuid[]) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
	new_conv_id uuid;
begin
	-- Insert a new row into api.conversation and capture the generated id into new_conv_id
    insert into api.conversation (name, type) values (_name, 'group')
	returning id into new_conv_id;

	-- Insert a row into api.participant using new_conv_id and auth helper function
    insert into api.participant (conversation_id, profile_id, role) values
	(new_conv_id, api.auth_profile_id(), 'admin'); -- creator's id already included here

	-- Insert a row into api.participant using new_conv_id and target_profile_id
    insert into api.participant (conversation_id, profile_id, role) select
	new_conv_id, unnest(target_profile_ids), 'member'
	where unnest(target_profile_ids) <> api.auth_profile_id();
	-- if creator's id also included in the target array, it will now be ignored

    return new_conv_id;
end;
$$;


ALTER FUNCTION api.create_group_chat(_name text, target_profile_ids uuid[]) OWNER TO postgres;

--
-- Name: hide_chat(uuid); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.hide_chat(target_conv_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
    update api.participant
    set status = 'hidden'
    where conversation_id = target_conv_id
      and profile_id = api.auth_profile_id();
end;
$$;


ALTER FUNCTION api.hide_chat(target_conv_id uuid) OWNER TO postgres;

--
-- Name: index(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.index() RETURNS public."text/html"
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION api.index() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: profile; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.profile (
    id uuid NOT NULL,
    display_name text,
    avatar_url text,
    last_active timestamp with time zone
);


ALTER TABLE api.profile OWNER TO postgres;

--
-- Name: register_account(text, text, text); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.register_account(_email text, _password text, _display_name text) RETURNS api.profile
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$ 
declare
	new_account_id uuid;
	new_profile api.profile;
begin
	-- inserting new account
	insert into private.account (email, password_hash) values
	(_email, crypt(_password, gen_salt('bf'))) 
	returning id into new_account_id;

	-- inserting new profile
	insert into api.profile (id, display_name, avatar_url, last_active) values
	(new_account_id, _display_name, '', now())
	returning * into new_profile;

	-- returning the new profile data
	return new_profile;
end;
$$;


ALTER FUNCTION api.register_account(_email text, _password text, _display_name text) OWNER TO postgres;

--
-- Name: render_archive(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.render_archive() RETURNS text
    LANGUAGE plpgsql
    AS $_$
declare
    html_output text;
begin
    -- Force PostgREST to return raw HTML
    perform set_config('response.headers', '[{"Content-Type": "text/html"}]', true);

    -- 1. Build the CSS for the chat cards
    html_output := $css$
    <style>
        .chat-card {
            display: flex; align-items: center; padding: 1.2rem 1.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05); cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            background: transparent;
            position: relative;
            overflow: hidden;
        }
        .chat-card::before {
            content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%;
            background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
            transform: scaleY(0); transition: transform 0.3s ease;
            transform-origin: left;
        }
        .chat-card:hover { background: rgba(255, 255, 255, 0.03); }
        .chat-card.active { 
            background: rgba(79, 172, 254, 0.1); 
        }
        .chat-card.active::before { transform: scaleY(1); }
        
        .chat-avatar {
            width: 48px; height: 48px; border-radius: 50%;
            background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); color: white;
            display: flex; justify-content: center; align-items: center;
            font-weight: 700; font-size: 1.3rem; margin-right: 1.2rem;
            flex-shrink: 0; text-transform: uppercase;
            box-shadow: 0 4px 15px rgba(79, 172, 254, 0.3);
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .chat-info { flex-grow: 1; overflow: hidden; }
        .chat-name { 
            font-weight: 600; color: #ffffff; margin-bottom: 0.3rem; 
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; 
            font-size: 1.05rem;
        }
        .chat-preview { 
            font-size: 0.9rem; color: #94a3b8; 
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; 
        }
    </style>
    $css$;

    -- 2. Query YOUR existing Archive view directly
    html_output := html_output || coalesce(
        (
            select string_agg(
                format(
                    $card$
                    <div class="chat-card" 
                        hx-post="/rpc/render_chat" 
     					hx-vals='{"_c_id": "%s"}'
     					hx-target="#chat-container" 
     					onclick="document.querySelectorAll('.chat-card').forEach(el => el.classList.remove('active')); this.classList.add('active');">
                        <div class="chat-avatar" style="filter: grayscale(100%%); opacity: 0.7;">%s</div>
                        <div class="chat-info" style="opacity: 0.7;">
                            <div class="chat-name">%s</div>
                            <div class="chat-preview">%s</div>
                        </div>
                    </div>
                    $card$,
                    conversation_id::text, -- Map to your view's ID column
                    left(coalesce(chat_name, 'C'), 1), -- Map to your view's Name column
                    coalesce(chat_name, 'Private Chat'),
                    coalesce(left(last_message_content, 40), 'Start the conversation...') -- Map to your view's message column
                ),
                ''
            )
            from api.archive
        ),
        -- 3. The Fallback: If the view returns 0 rows
        '<div style="text-align: center; color: #94a3b8; padding: 4rem 1rem; animation: fadeIn 0.5s ease;">
            <div style="font-size: 3rem; margin-bottom: 1rem; filter: drop-shadow(0 0 10px rgba(255,255,255,0.1)); opacity: 0.5;">🗄️</div>
            You have no archived conversations.
        </div>'
    );

    return html_output;
end;
$_$;


ALTER FUNCTION api.render_archive() OWNER TO postgres;

--
-- Name: render_chat(uuid); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.render_chat(_c_id uuid) RETURNS text
    LANGUAGE plpgsql
    AS $_$
declare
    html_output text;
    chat_header_name text;
begin
    -- Force raw HTML output
    perform set_config('response.headers', '[{"Content-Type": "text/html"}]', true);

    -- 1. Fetch the Chat Name for the header
    select chat_name into chat_header_name from api.inbox where conversation_id = _c_id;

    -- 2. Build the CSS and Layout
    html_output := $css$
    <style>
        .chat-window { display: flex; flex-direction: column; height: 100%; width: 100%; background: transparent; animation: fadeIn 0.3s ease; }
        .chat-header { 
            padding: 1.2rem 2rem; 
            border-bottom: 1px solid rgba(255, 255, 255, 0.05); 
            background: rgba(15, 23, 42, 0.6); 
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            display: flex; align-items: center; 
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            z-index: 5;
        }
        .chat-messages { 
            flex-grow: 1; overflow-y: auto; padding: 2rem; 
            display: flex; flex-direction: column; gap: 1.2rem; 
        }
        
        .chat-messages::-webkit-scrollbar { width: 6px; }
        .chat-messages::-webkit-scrollbar-track { background: transparent; }
        .chat-messages::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 10px; }

        .msg { 
            max-width: 75%; padding: 1rem 1.2rem; 
            border-radius: 16px; font-size: 1rem; line-height: 1.5; 
            position: relative; animation: slideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1); 
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .msg-me { 
            align-self: flex-end; 
            background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); 
            color: white; 
            border-bottom-right-radius: 4px; 
            box-shadow: 0 4px 15px rgba(79, 172, 254, 0.25);
        }
        .msg-them { 
            align-self: flex-start; 
            background: rgba(30, 41, 59, 0.8); 
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            color: var(--text); 
            border-bottom-left-radius: 4px; 
        }
        .msg-time { font-size: 0.75rem; opacity: 0.7; margin-top: 0.5rem; display: block; text-align: right; }
        .msg-sender { font-size: 0.8rem; font-weight: 700; color: #4facfe; margin-bottom: 0.4rem; text-shadow: 0 0 10px rgba(79,172,254,0.3); }

        .msg-actions { 
            position: absolute; top: -12px; left: -12px; 
            display: flex; gap: 0.4rem; opacity: 0; 
            transition: opacity 0.2s ease; 
        }
        .msg:hover .msg-actions { opacity: 1; }
        .action-btn { 
            background: rgba(15, 23, 42, 0.95); border: 1px solid rgba(255, 255, 255, 0.15); 
            color: white; border-radius: 50%; width: 30px; height: 30px; 
            display: flex; justify-content: center; align-items: center; 
            cursor: pointer; font-size: 0.8rem; box-shadow: 0 2px 8px rgba(0,0,0,0.3); 
            transition: all 0.2s ease; padding: 0;
        }
        .action-btn:hover { background: #4facfe; transform: scale(1.1); border-color: #4facfe; }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(10px) scale(0.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        .chat-input-area { 
            padding: 1.5rem 2rem; 
            border-top: 1px solid rgba(255, 255, 255, 0.05); 
            background: rgba(15, 23, 42, 0.8); 
            backdrop-filter: blur(16px);
        }
        .chat-form { display: flex; gap: 1rem; position: relative; }
        .chat-input { 
            flex-grow: 1; 
            background: rgba(0, 0, 0, 0.3); 
            border: 1px solid rgba(255, 255, 255, 0.1); 
            border-radius: 20px; 
            padding: 1rem 1.5rem; 
            color: white; outline: none; 
            font-family: 'Outfit', sans-serif;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        .chat-input:focus { 
            border-color: rgba(79, 172, 254, 0.5); 
            background: rgba(0, 0, 0, 0.5);
            box-shadow: 0 0 0 4px rgba(79, 172, 254, 0.1);
        }
        .chat-input::placeholder { color: #64748b; }
        
        .send-btn { 
            background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); 
            color: white; border: none; border-radius: 20px; 
            padding: 0 2rem; font-weight: 700; cursor: pointer; 
            font-family: 'Outfit', sans-serif; font-size: 1rem;
            transition: all 0.2s ease;
            box-shadow: 0 4px 15px rgba(79, 172, 254, 0.3);
        }
        .send-btn:hover { 
            transform: translateY(-2px); 
            box-shadow: 0 6px 20px rgba(79, 172, 254, 0.4); 
        }
        .send-btn:active { transform: translateY(1px); }
    </style>
    $css$;

    -- 3. Header Construction
    html_output := html_output || format(
        '<div class="chat-window">
            <div class="chat-header">
                <div class="chat-avatar" style="width:40px; height:40px; font-size:1.1rem; margin-right:1rem; border-radius:50%%; background:linear-gradient(135deg, #00f2fe 0%%, #4facfe 100%%); color:white; display:flex; justify-content:center; align-items:center; font-weight:700; box-shadow: 0 4px 10px rgba(79,172,254,0.3);">%s</div>
                <h3 style="margin:0; font-size:1.2rem; font-weight:700; color:white;">%s</h3>
            </div>
            <div class="chat-messages" id="message-list">',
        left(coalesce(chat_header_name, 'U'), 1),
        coalesce(chat_header_name, 'Unknown Chat')
    );

    -- 4. Message Bubble Generation
    html_output := html_output || coalesce(
        (
            select string_agg(
                format(
                    '<div class="msg %s" id="msg-%s">
                        %s
                        %s
                        <span class="msg-time">%s</span>
                        %s
                    </div>',
                    case when m.sender_id = api.auth_profile_id() then 'msg-me' else 'msg-them' end,
                    m.id::text,
                    case when m.sender_id != api.auth_profile_id() then '<div class="msg-sender">' || coalesce(p.display_name, 'Unknown') || '</div>' else '' end,
                    replace(replace(m.content, '&', '&amp;'), '<', '&lt;'),
                    to_char(m.sent_at, 'HH12:MI AM'),
                    case when m.sender_id = api.auth_profile_id() then 
                        format('<div class="msg-actions">
                            <button class="action-btn" title="Edit" hx-post="/rpc/render_edit_message" hx-vals=''{"_msg_id": "%s"}'' hx-target="#msg-%s" hx-swap="outerHTML">✏️</button>
                            <button class="action-btn" title="Delete" hx-delete="/message?id=eq.%s" hx-swap="none" hx-on::after-request="if(event.detail.successful) this.closest(''.msg'').remove()" hx-confirm="Delete this message?">🗑️</button>
                        </div>', m.id::text, m.id::text, m.id::text)
                    else '' end
                ),
                '' order by m.sent_at asc
            )
            from api.message m
            join api.profile p on m.sender_id = p.id
            where m.conversation_id = _c_id
        ),
        '<div style="text-align:center; color:#94a3b8; margin-top:3rem; animation:fadeIn 0.5s ease;">
            <div style="font-size:2.5rem; margin-bottom:1rem; opacity:0.8;">👋</div>
            No messages yet. Break the ice!
        </div>'
    );

    -- 5. Input Area Construction
    html_output := html_output || format(
        '</div>
            <div class="chat-input-area">
                <form class="chat-form" 
                      hx-ext="json-enc"
                      hx-post="/message" 
                      hx-headers=''{"Prefer": "return=representation"}''
                      hx-swap="none"
                      hx-on::after-request="if(event.detail.successful) { 
                          const resp = JSON.parse(event.detail.xhr.response);
                          if(resp && resp.length > 0) {
                              htmx.ajax(''POST'', ''/rpc/render_message_bubble'', {
                                  target: ''#message-list'', 
                                  swap: ''beforeend'', 
                                  values: {_msg_id: resp[0].id}
                              });
                              this.reset();
                              setTimeout(() => {
                                  var msgList = document.getElementById(''message-list'');
                                  if(msgList) msgList.scrollTop = msgList.scrollHeight;
                              }, 100);
                          }
                      }">
                    <input type="hidden" name="conversation_id" value="%s">
                    <input type="text" name="content" class="chat-input" placeholder="Type a message..." required autocomplete="off" autofocus>
                    <button type="submit" class="send-btn">Send</button>
                </form>
            </div>
        </div>
        <script>
            // Auto scroll to bottom
            var msgList = document.getElementById("message-list");
            if(msgList) msgList.scrollTop = msgList.scrollHeight;
        </script>',
        _c_id::text
    );

    return html_output;
end;
$_$;


ALTER FUNCTION api.render_chat(_c_id uuid) OWNER TO postgres;

--
-- Name: render_edit_message(uuid); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.render_edit_message(_msg_id uuid) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    msg_content text;
    html_output text;
begin
    -- Force raw HTML output
    perform set_config('response.headers', '[{"Content-Type": "text/html"}]', true);

    -- 1. Fetch the current content of the message
    select content into msg_content 
    from api.message 
    where id = _msg_id 
      and sender_id = api.auth_profile_id();

    -- If not found or not owner, return empty
    if msg_content is null then
        return '';
    end if;

    -- 2. Build the inline edit form
    -- It completely replaces the outer div.msg with an editing interface
    -- It uses PATCH /message to update and then fetches the HTML bubble
    html_output := format(
        '<div class="msg msg-me" id="msg-%s" style="padding: 0.5rem; background: rgba(15, 23, 42, 0.95); border: 1px solid #4facfe;">
            <form class="chat-form" style="margin: 0;"
                  hx-ext="json-enc"
                  hx-patch="/message?id=eq.%s" 
                  hx-swap="none"
                  hx-on::after-request="if(event.detail.successful) {
                      htmx.ajax(''POST'', ''/rpc/render_message_bubble'', {
                          target: ''#msg-%s'', 
                          swap: ''outerHTML'', 
                          values: {_msg_id: ''%s''}
                      });
                  }">
                <input type="text" name="content" class="chat-input" style="padding: 0.5rem 1rem; border-radius: 10px; border: 1px solid rgba(79, 172, 254, 0.5); background: rgba(0,0,0,0.5); width: 100%%; margin-bottom: 0.5rem;" value="%s" required autocomplete="off" autofocus>
                <div style="display: flex; justify-content: flex-end; gap: 0.5rem;">
                    <!-- Cancel fetches the original HTML bubble via render_message_bubble -->
                    <button type="button" class="send-btn" style="padding: 0.3rem 1rem; font-size: 0.8rem; background: transparent; border: 1px solid rgba(255,255,255,0.2); box-shadow: none;" 
                            hx-post="/rpc/render_message_bubble" 
                            hx-vals=''{"_msg_id": "%s"}'' 
                            hx-target="#msg-%s" 
                            hx-swap="outerHTML">Cancel</button>
                    
                    <button type="submit" class="send-btn" style="padding: 0.3rem 1rem; font-size: 0.8rem;">Save</button>
                </div>
            </form>
        </div>',
        _msg_id::text,
        _msg_id::text,
        _msg_id::text,
        _msg_id::text,
        replace(replace(msg_content, '&', '&amp;'), '"', '&quot;'),
        _msg_id::text, 
        _msg_id::text
    );

    return html_output;
end;
$$;


ALTER FUNCTION api.render_edit_message(_msg_id uuid) OWNER TO postgres;

--
-- Name: render_inbox(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.render_inbox() RETURNS text
    LANGUAGE plpgsql
    AS $_$
declare
    html_output text;
begin
    -- Force PostgREST to return raw HTML
    perform set_config('response.headers', '[{"Content-Type": "text/html"}]', true);

    -- 1. Build the CSS for the chat cards
    html_output := $css$
    <style>
        .chat-card {
            display: flex; align-items: center; padding: 1.2rem 1.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05); cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            background: transparent;
            position: relative;
            overflow: hidden;
        }
        .chat-card::before {
            content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%;
            background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
            transform: scaleY(0); transition: transform 0.3s ease;
            transform-origin: left;
        }
        .chat-card:hover { background: rgba(255, 255, 255, 0.03); }
        .chat-card.active { 
            background: rgba(79, 172, 254, 0.1); 
        }
        .chat-card.active::before { transform: scaleY(1); }
        
        .chat-avatar {
            width: 48px; height: 48px; border-radius: 50%;
            background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); color: white;
            display: flex; justify-content: center; align-items: center;
            font-weight: 700; font-size: 1.3rem; margin-right: 1.2rem;
            flex-shrink: 0; text-transform: uppercase;
            box-shadow: 0 4px 15px rgba(79, 172, 254, 0.3);
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .chat-info { flex-grow: 1; overflow: hidden; }
        .chat-name { 
            font-weight: 600; color: #ffffff; margin-bottom: 0.3rem; 
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; 
            font-size: 1.05rem;
        }
        .chat-preview { 
            font-size: 0.9rem; color: #94a3b8; 
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; 
        }
    </style>
    $css$;

    -- 2. Query YOUR existing Inbox view directly
    html_output := html_output || coalesce(
        (
            select string_agg(
                format(
                    $card$
                    <div class="chat-card" 
                        hx-post="/rpc/render_chat" 
     					hx-vals='{"_c_id": "%s"}'
     					hx-target="#chat-container" 
     					onclick="document.querySelectorAll('.chat-card').forEach(el => el.classList.remove('active')); this.classList.add('active');">
                        <div class="chat-avatar">%s</div>
                        <div class="chat-info">
                            <div class="chat-name">%s</div>
                            <div class="chat-preview">%s</div>
                        </div>
                    </div>
                    $card$,
                    conversation_id::text, -- Map to your view's ID column
                    left(coalesce(chat_name, 'C'), 1), -- Map to your view's Name column
                    coalesce(chat_name, 'Private Chat'),
                    coalesce(left(last_message_content, 40), 'Start the conversation...') -- Map to your view's message column
                ),
                ''
            )
            from api.inbox
        ),
        -- 3. The Fallback: If the view returns 0 rows
        '<div style="text-align: center; color: #94a3b8; padding: 4rem 1rem; animation: fadeIn 0.5s ease;">
            <div style="font-size: 3rem; margin-bottom: 1rem; filter: drop-shadow(0 0 10px rgba(255,255,255,0.1));">📭</div>
            You have no active conversations.<br>Click + to start one.
        </div>'
    );

    return html_output;
end;
$_$;


ALTER FUNCTION api.render_inbox() OWNER TO postgres;

--
-- Name: render_message_bubble(uuid); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.render_message_bubble(_msg_id uuid) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    html_output text;
begin
    -- Force raw HTML output
    perform set_config('response.headers', '[{"Content-Type": "text/html"}]', true);

    select format(
        '<div class="msg %s" id="msg-%s" style="animation: fadeIn 0.3s ease;">
            %s
            %s
            <span class="msg-time">%s</span>
            %s
        </div>',
        case when m.sender_id = api.auth_profile_id() then 'msg-me' else 'msg-them' end,
        m.id::text,
        case when m.sender_id != api.auth_profile_id() then '<div class="msg-sender">' || coalesce(p.display_name, 'Unknown') || '</div>' else '' end,
        replace(replace(m.content, '&', '&amp;'), '<', '&lt;'), -- Basic escaping just in case
        to_char(m.sent_at, 'HH12:MI AM'),
        case when m.sender_id = api.auth_profile_id() then 
            format('<div class="msg-actions">
                <button class="action-btn" title="Edit" hx-post="/rpc/render_edit_message" hx-vals=''{"_msg_id": "%s"}'' hx-target="#msg-%s" hx-swap="outerHTML">✏️</button>
                <button class="action-btn" title="Delete" hx-delete="/message?id=eq.%s" hx-swap="none" hx-on::after-request="if(event.detail.successful) this.closest(''.msg'').remove()" hx-confirm="Delete this message?">🗑️</button>
            </div>', m.id::text, m.id::text, m.id::text)
        else '' end
    )
    into html_output
    from api.message m
    join api.profile p on m.sender_id = p.id
    where m.id = _msg_id;

    return coalesce(html_output, '');
end;
$$;


ALTER FUNCTION api.render_message_bubble(_msg_id uuid) OWNER TO postgres;

--
-- Name: render_settings(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.render_settings() RETURNS text
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION api.render_settings() OWNER TO postgres;

--
-- Name: unarchive_chat(uuid); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.unarchive_chat(target_conv_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
    update api.participant
    set status = 'active'
    where conversation_id = target_conv_id
      and profile_id = api.auth_profile_id();
end;
$$;


ALTER FUNCTION api.unarchive_chat(target_conv_id uuid) OWNER TO postgres;

--
-- Name: activate_chat(); Type: FUNCTION; Schema: private; Owner: postgres
--

CREATE FUNCTION private.activate_chat() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
    -- If a new message arrives, set everyone in the room back to active
    update api.participant set status = 'active'
    where conversation_id = NEW.conversation_id and status = 'hidden';
    return NEW;
end;
$$;


ALTER FUNCTION private.activate_chat() OWNER TO postgres;

--
-- Name: broadcast_conversation_events(); Type: FUNCTION; Schema: private; Owner: postgres
--

CREATE FUNCTION private.broadcast_conversation_events() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    payload jsonb;
begin
    if TG_OP = 'DELETE' then
        payload := jsonb_build_object(
            'event_type', 'DELETE',
            'conversation_id', OLD.id
        );
        perform pg_notify('conversation_stream', payload::text);
        return OLD;
        
    elsif TG_OP = 'UPDATE' then
        payload := jsonb_build_object(
            'event_type', TG_OP,
            'conversation_id', NEW.id,
            'name', NEW.name,
            'avatar_url', NEW.avatar_url
        );
        perform pg_notify('conversation_stream', payload::text);
        return NEW;
    end if;
    
    return null;
end;
$$;


ALTER FUNCTION private.broadcast_conversation_events() OWNER TO postgres;

--
-- Name: broadcast_message_events(); Type: FUNCTION; Schema: private; Owner: postgres
--

CREATE FUNCTION private.broadcast_message_events() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    payload jsonb;
begin
    if TG_OP = 'DELETE' then
        payload := jsonb_build_object(
            'event_type', 'DELETE',
            'message_id', OLD.id,
            'conversation_id', OLD.conversation_id
        );
        perform pg_notify('chat_stream', payload::text);
        return OLD;
    else
        payload := jsonb_build_object(
            'event_type', TG_OP, -- Will dynamically inject 'INSERT' or 'UPDATE'
            'message_id', NEW.id,
            'conversation_id', NEW.conversation_id,
            'sender_id', NEW.sender_id,
            'content', NEW.content,
            'sent_at', NEW.sent_at
        );
        perform pg_notify('chat_stream', payload::text);
        return NEW;
    end if;
end;
$$;


ALTER FUNCTION private.broadcast_message_events() OWNER TO postgres;

--
-- Name: get_my_conversation_ids(); Type: FUNCTION; Schema: private; Owner: postgres
--

CREATE FUNCTION private.get_my_conversation_ids() RETURNS SETOF uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
    select conversation_id 
    from api.participant 
    where profile_id = api.auth_profile_id();
$$;


ALTER FUNCTION private.get_my_conversation_ids() OWNER TO postgres;

--
-- Name: is_admin_of(uuid); Type: FUNCTION; Schema: private; Owner: postgres
--

CREATE FUNCTION private.is_admin_of(target_conv_id uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
    select exists (
        select 1 
        from api.participant
        where conversation_id = target_conv_id
        and profile_id = api.auth_profile_id()
        and role = 'admin'
    );
$$;


ALTER FUNCTION private.is_admin_of(target_conv_id uuid) OWNER TO postgres;

--
-- Name: prevent_blocked_message(); Type: FUNCTION; Schema: private; Owner: postgres
--

CREATE FUNCTION private.prevent_blocked_message() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
    is_direct boolean;
    other_profile_id uuid;
    block_exists boolean;
begin
    -- check for DMs only
    select type = 'direct' into is_direct
    from api.conversation
    where id = NEW.conversation_id;

    if is_direct then
        -- find the other person in this DM
        select profile_id into other_profile_id
        from api.participant
        where conversation_id = NEW.conversation_id
          and profile_id != NEW.sender_id; -- NEW.sender_id is the sender

        -- Check the block list in both directions
        select exists (
            select 1 from api.block
            where (blocker_id = NEW.sender_id and blocked_id = other_profile_id)
               or (blocker_id = other_profile_id and blocked_id = NEW.sender_id)
        ) into block_exists;

        -- If a block exists, throw error
        if block_exists then
            raise exception 'Message could not be sent.';
        end if;
    end if;

    return NEW;
end;
$$;


ALTER FUNCTION private.prevent_blocked_message() OWNER TO postgres;

--
-- Name: prevent_last_admin_leave(); Type: FUNCTION; Schema: private; Owner: postgres
--

CREATE FUNCTION private.prevent_last_admin_leave() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    remaining_admin_count int;
begin
    if OLD.role = 'admin' then
        
        -- Counting other admins
        select count(*) into remaining_admin_count
        from api.participant
        where conversation_id = OLD.conversation_id 
          and role = 'admin' 
          and profile_id != OLD.profile_id; -- Don't count the person leaving

        if remaining_admin_count = 0 then
            raise exception 'You are the last admin. Promote another member to admin before leaving, or delete the group entirely.';
        end if;
    end if;

    return OLD;
end;
$$;


ALTER FUNCTION private.prevent_last_admin_leave() OWNER TO postgres;

--
-- Name: algorithm_sign(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.algorithm_sign(signables text, secret text, algorithm text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
WITH
  alg AS (
    SELECT CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE '' END AS id)  -- hmac throws error
SELECT public.url_encode(public.hmac(signables, secret, alg.id)) FROM alg;
$$;


ALTER FUNCTION public.algorithm_sign(signables text, secret text, algorithm text) OWNER TO postgres;

--
-- Name: sign(json, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sign(payload json, secret text, algorithm text DEFAULT 'HS256'::text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
WITH
  header AS (
    SELECT public.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8')) AS data
    ),
  payload AS (
    SELECT public.url_encode(convert_to(payload::text, 'utf8')) AS data
    ),
  signables AS (
    SELECT header.data || '.' || payload.data AS data FROM header, payload
    )
SELECT
    signables.data || '.' ||
    public.algorithm_sign(signables.data, secret, algorithm) FROM signables;
$$;


ALTER FUNCTION public.sign(payload json, secret text, algorithm text) OWNER TO postgres;

--
-- Name: try_cast_double(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.try_cast_double(inp text) RETURNS double precision
    LANGUAGE plpgsql IMMUTABLE
    AS $$
  BEGIN
    BEGIN
      RETURN inp::double precision;
    EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
    END;
  END;
$$;


ALTER FUNCTION public.try_cast_double(inp text) OWNER TO postgres;

--
-- Name: url_decode(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.url_decode(data text) RETURNS bytea
    LANGUAGE sql IMMUTABLE
    AS $$
WITH t AS (SELECT translate(data, '-_', '+/') AS trans),
     rem AS (SELECT length(t.trans) % 4 AS remainder FROM t) -- compute padding size
    SELECT decode(
        t.trans ||
        CASE WHEN rem.remainder > 0
           THEN repeat('=', (4 - rem.remainder))
           ELSE '' END,
    'base64') FROM t, rem;
$$;


ALTER FUNCTION public.url_decode(data text) OWNER TO postgres;

--
-- Name: url_encode(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.url_encode(data bytea) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
    SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$;


ALTER FUNCTION public.url_encode(data bytea) OWNER TO postgres;

--
-- Name: verify(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verify(token text, secret text, algorithm text DEFAULT 'HS256'::text) RETURNS TABLE(header json, payload json, valid boolean)
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT
    jwt.header AS header,
    jwt.payload AS payload,
    jwt.signature_ok AND tstzrange(
      to_timestamp(public.try_cast_double(jwt.payload->>'nbf')),
      to_timestamp(public.try_cast_double(jwt.payload->>'exp'))
    ) @> CURRENT_TIMESTAMP AS valid
  FROM (
    SELECT
      convert_from(public.url_decode(r[1]), 'utf8')::json AS header,
      convert_from(public.url_decode(r[2]), 'utf8')::json AS payload,
      r[3] = public.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS signature_ok
    FROM regexp_split_to_array(token, '\.') r
  ) jwt
$$;


ALTER FUNCTION public.verify(token text, secret text, algorithm text) OWNER TO postgres;

--
-- Name: conversation; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.conversation (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type text,
    created_at timestamp with time zone DEFAULT now(),
    name text,
    avatar_url text,
    CONSTRAINT conversation_type_check CHECK (((type = 'direct'::text) OR (type = 'group'::text)))
);


ALTER TABLE api.conversation OWNER TO postgres;

--
-- Name: message; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.message (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid,
    sender_id uuid DEFAULT api.auth_profile_id(),
    content text NOT NULL,
    sent_at timestamp with time zone DEFAULT now()
);


ALTER TABLE api.message OWNER TO postgres;

--
-- Name: participant; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.participant (
    conversation_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    joined_at timestamp with time zone DEFAULT now(),
    role text,
    status text DEFAULT 'active'::text NOT NULL,
    CONSTRAINT participant_role_check CHECK (((role = 'member'::text) OR (role = 'admin'::text))),
    CONSTRAINT participant_status_check CHECK ((status = ANY (ARRAY['active'::text, 'hidden'::text])))
);


ALTER TABLE api.participant OWNER TO postgres;

--
-- Name: archive; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.archive AS
 SELECT c.id AS conversation_id,
    c.type AS conversation_type,
    COALESCE(c.name, other_profile.display_name) AS chat_name,
    COALESCE(c.avatar_url, other_profile.avatar_url) AS chat_avatar,
    last_msg.content AS last_message_content,
    last_msg.sent_at AS last_message_at
   FROM ((((api.participant my_p
     JOIN api.conversation c ON ((my_p.conversation_id = c.id)))
     LEFT JOIN api.participant other_p ON (((c.type = 'direct'::text) AND (other_p.conversation_id = c.id) AND (other_p.profile_id <> my_p.profile_id))))
     LEFT JOIN api.profile other_profile ON ((other_p.profile_id = other_profile.id)))
     LEFT JOIN LATERAL ( SELECT m.content,
            m.sent_at
           FROM api.message m
          WHERE (m.conversation_id = c.id)
          ORDER BY m.sent_at DESC
         LIMIT 1) last_msg ON (true))
  WHERE ((my_p.profile_id = api.auth_profile_id()) AND (my_p.status = 'hidden'::text));


ALTER VIEW api.archive OWNER TO postgres;

--
-- Name: block; Type: TABLE; Schema: api; Owner: postgres
--

CREATE TABLE api.block (
    blocker_id uuid DEFAULT api.auth_profile_id() NOT NULL,
    blocked_id uuid NOT NULL,
    CONSTRAINT block_check CHECK ((blocked_id <> blocker_id))
);


ALTER TABLE api.block OWNER TO postgres;

--
-- Name: inbox; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.inbox AS
 SELECT c.id AS conversation_id,
    c.type AS conversation_type,
    COALESCE(c.name, other_profile.display_name) AS chat_name,
    COALESCE(c.avatar_url, other_profile.avatar_url) AS chat_avatar,
    last_msg.content AS last_message_content,
    last_msg.sent_at AS last_message_at
   FROM ((((api.participant my_p
     JOIN api.conversation c ON ((my_p.conversation_id = c.id)))
     LEFT JOIN api.participant other_p ON (((c.type = 'direct'::text) AND (other_p.conversation_id = c.id) AND (other_p.profile_id <> my_p.profile_id))))
     LEFT JOIN api.profile other_profile ON ((other_p.profile_id = other_profile.id)))
     LEFT JOIN LATERAL ( SELECT m.content,
            m.sent_at
           FROM api.message m
          WHERE (m.conversation_id = c.id)
          ORDER BY m.sent_at DESC
         LIMIT 1) last_msg ON (true))
  WHERE ((my_p.profile_id = api.auth_profile_id()) AND (my_p.status = 'active'::text));


ALTER VIEW api.inbox OWNER TO postgres;

--
-- Name: account; Type: TABLE; Schema: private; Owner: postgres
--

CREATE TABLE private.account (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    role name DEFAULT 'authenticated_user'::name,
    token_version integer DEFAULT 1
);


ALTER TABLE private.account OWNER TO postgres;

--
-- Name: my_account; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.my_account WITH (security_invoker='true') AS
 SELECT email
   FROM private.account;


ALTER VIEW api.my_account OWNER TO postgres;

--
-- Data for Name: block; Type: TABLE DATA; Schema: api; Owner: postgres
--

COPY api.block (blocker_id, blocked_id) FROM stdin;
\.


--
-- Data for Name: conversation; Type: TABLE DATA; Schema: api; Owner: postgres
--

COPY api.conversation (id, type, created_at, name, avatar_url) FROM stdin;
c33af1a5-3330-432c-8705-1c5b90937c85	direct	2026-04-28 15:02:30.297333+00	\N	\N
85a672d0-ef9a-4080-9765-136b9a091eb0	direct	2026-04-30 08:11:03.56647+00	\N	\N
b5621afd-94fa-45af-a066-c6e376b34085	group	2026-04-29 08:26:28.780601+00	The Niggers	https://example.com/nigga.png
\.


--
-- Data for Name: message; Type: TABLE DATA; Schema: api; Owner: postgres
--

COPY api.message (id, conversation_id, sender_id, content, sent_at) FROM stdin;
bd7efbf2-3417-4d37-aa55-4445573d83d3	c33af1a5-3330-432c-8705-1c5b90937c85	938b53d7-2f8e-4169-bd43-89ac36cfe132	Hello nigga. Picking Cotton?!?	2026-04-28 15:29:31.878738+00
0a249f9d-61ff-4c22-b314-d2ca8287a549	b5621afd-94fa-45af-a066-c6e376b34085	938b53d7-2f8e-4169-bd43-89ac36cfe132	Can I activate my own hidden chat through the backend???	2026-04-29 16:13:42.740413+00
a48ca84c-22c5-45e8-9d9d-fd5563af228f	85a672d0-ef9a-4080-9765-136b9a091eb0	b33a838e-944d-4a7a-8365-64c82b08adf0	Hi babygirl	2026-04-30 08:25:25.90627+00
a011c804-bd78-4b4c-9547-8ff745999c77	85a672d0-ef9a-4080-9765-136b9a091eb0	b33a838e-944d-4a7a-8365-64c82b08adf0	Sorry for blocking you	2026-04-30 08:26:33.427683+00
6816a31b-5533-4ea1-b0cd-b3e310ca9a56	85a672d0-ef9a-4080-9765-136b9a091eb0	b33a838e-944d-4a7a-8365-64c82b08adf0	Babe	2026-04-30 14:49:50.627868+00
7b5ecf65-39be-4bfa-9fd9-cc974f40ab39	85a672d0-ef9a-4080-9765-136b9a091eb0	b33a838e-944d-4a7a-8365-64c82b08adf0	Yo yo chiki chiki	2026-04-30 14:53:18.07079+00
17ee5c3c-29f3-4fb4-b091-19ccdb53baf4	85a672d0-ef9a-4080-9765-136b9a091eb0	b33a838e-944d-4a7a-8365-64c82b08adf0	Hello chat stream	2026-04-30 14:55:32.075165+00
fc00aef5-7cb0-4a16-8204-ff9bea1a6e09	85a672d0-ef9a-4080-9765-136b9a091eb0	b33a838e-944d-4a7a-8365-64c82b08adf0	Hello chat stream	2026-04-30 15:00:04.212806+00
86f2387a-57be-4fe4-9aa2-857d99d30777	85a672d0-ef9a-4080-9765-136b9a091eb0	b33a838e-944d-4a7a-8365-64c82b08adf0	Hello chat stream	2026-04-30 15:00:52.984049+00
37d659bd-42f6-4d56-b232-3cba6e2e512c	85a672d0-ef9a-4080-9765-136b9a091eb0	f8d205ad-e2ad-4057-a16c-4463a8541863	hey who is this	2026-05-01 04:56:32.525858+00
d7905149-34e0-4f13-85b3-564c6cce6614	b5621afd-94fa-45af-a066-c6e376b34085	f8d205ad-e2ad-4057-a16c-4463a8541863	yes you can nigga	2026-05-01 04:57:04.217311+00
fa520855-2f91-4234-a0d0-83ed875ec4eb	b5621afd-94fa-45af-a066-c6e376b34085	938b53d7-2f8e-4169-bd43-89ac36cfe132	uh huh	2026-05-01 04:59:16.344397+00
339079b4-8ef9-4f04-834b-d17851654517	c33af1a5-3330-432c-8705-1c5b90937c85	938b53d7-2f8e-4169-bd43-89ac36cfe132	hey why you dont answer huh?!?!	2026-05-01 08:06:15.784998+00
29660f65-176d-4dd8-ab0c-014e0d3b215a	c33af1a5-3330-432c-8705-1c5b90937c85	ae7045fe-62bd-4299-bd47-13e5e5d6d3fa	what the shit is wrong with you?!	2026-05-01 08:07:04.315611+00
58551469-c067-4092-a266-54a9435752ec	b5621afd-94fa-45af-a066-c6e376b34085	ae7045fe-62bd-4299-bd47-13e5e5d6d3fa	oy fuck off why is my NAME Nigger? I am gonna fuck all of yall	2026-05-01 08:53:36.067379+00
663acc1e-8115-4de6-a93d-8766c6f2448d	c33af1a5-3330-432c-8705-1c5b90937c85	ae7045fe-62bd-4299-bd47-13e5e5d6d3fa	yo bro whats up, doggy doggy doggy	2026-05-01 10:31:42.801408+00
\.


--
-- Data for Name: participant; Type: TABLE DATA; Schema: api; Owner: postgres
--

COPY api.participant (conversation_id, profile_id, joined_at, role, status) FROM stdin;
c33af1a5-3330-432c-8705-1c5b90937c85	ae7045fe-62bd-4299-bd47-13e5e5d6d3fa	2026-04-28 15:02:30.297333+00	member	active
b5621afd-94fa-45af-a066-c6e376b34085	ae7045fe-62bd-4299-bd47-13e5e5d6d3fa	2026-04-29 08:26:28.780601+00	admin	active
b5621afd-94fa-45af-a066-c6e376b34085	f8d205ad-e2ad-4057-a16c-4463a8541863	2026-04-29 10:34:01.129146+00	member	active
b5621afd-94fa-45af-a066-c6e376b34085	938b53d7-2f8e-4169-bd43-89ac36cfe132	2026-04-29 08:26:28.780601+00	member	active
c33af1a5-3330-432c-8705-1c5b90937c85	938b53d7-2f8e-4169-bd43-89ac36cfe132	2026-04-28 15:02:30.297333+00	member	active
85a672d0-ef9a-4080-9765-136b9a091eb0	b33a838e-944d-4a7a-8365-64c82b08adf0	2026-04-30 08:11:03.56647+00	member	active
85a672d0-ef9a-4080-9765-136b9a091eb0	f8d205ad-e2ad-4057-a16c-4463a8541863	2026-04-30 08:11:03.56647+00	member	active
\.


--
-- Data for Name: profile; Type: TABLE DATA; Schema: api; Owner: postgres
--

COPY api.profile (id, display_name, avatar_url, last_active) FROM stdin;
938b53d7-2f8e-4169-bd43-89ac36cfe132	Test User 3		2026-04-25 15:13:08.974638+00
b33a838e-944d-4a7a-8365-64c82b08adf0	Test User		2026-04-29 08:17:41.244268+00
f8d205ad-e2ad-4057-a16c-4463a8541863	Test User 2		2026-04-29 08:17:57.850153+00
ae7045fe-62bd-4299-bd47-13e5e5d6d3fa	Alif Ilhan	https://thumbs.dreamstime.com/b/black-guy-showing-hand-1657857.jpg	2026-04-25 15:05:40.217538+00
\.


--
-- Data for Name: account; Type: TABLE DATA; Schema: private; Owner: postgres
--

COPY private.account (id, email, password_hash, role, token_version) FROM stdin;
938b53d7-2f8e-4169-bd43-89ac36cfe132	test3@example.com	$2a$06$xjMkD6JrsZScVUfnsOKNK.mTCdXJDju9XK1N9496/ZS2gSr7Xpk/e	authenticated_user	1
b33a838e-944d-4a7a-8365-64c82b08adf0	test@example.com	$2a$06$ZOH5rMVyqG0WrR2ZSTJaVOjcThwFR9fd9WKFQdxulnLrMd5/oEUQC	authenticated_user	1
f8d205ad-e2ad-4057-a16c-4463a8541863	test2@example.com	$2a$06$q315T26wHB0k2Olsenre4eY/0sBUoRsADU.6IdO8ViH9sqBYRt4qS	authenticated_user	1
ae7045fe-62bd-4299-bd47-13e5e5d6d3fa	alif@ilhan.com	$2a$06$RX2LoRqWwfM6dLQT9j11I.jRYwiXZvuqAwlBOT4d0BX3H2sBSrePa	authenticated_user	3
\.


--
-- Name: block block_pkey; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.block
    ADD CONSTRAINT block_pkey PRIMARY KEY (blocker_id, blocked_id);


--
-- Name: conversation conversation_pkey; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.conversation
    ADD CONSTRAINT conversation_pkey PRIMARY KEY (id);


--
-- Name: message message_pkey; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);


--
-- Name: participant participant_pkey; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.participant
    ADD CONSTRAINT participant_pkey PRIMARY KEY (conversation_id, profile_id);


--
-- Name: profile profile_pkey; Type: CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (id);


--
-- Name: account account_email_key; Type: CONSTRAINT; Schema: private; Owner: postgres
--

ALTER TABLE ONLY private.account
    ADD CONSTRAINT account_email_key UNIQUE (email);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: private; Owner: postgres
--

ALTER TABLE ONLY private.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: message_sender_idx; Type: INDEX; Schema: api; Owner: postgres
--

CREATE INDEX message_sender_idx ON api.message USING btree (sender_id);


--
-- Name: message_time_idx; Type: INDEX; Schema: api; Owner: postgres
--

CREATE INDEX message_time_idx ON api.message USING btree (conversation_id, sent_at DESC);


--
-- Name: participant_profile_idx; Type: INDEX; Schema: api; Owner: postgres
--

CREATE INDEX participant_profile_idx ON api.participant USING btree (profile_id);


--
-- Name: message activate_chats; Type: TRIGGER; Schema: api; Owner: postgres
--

CREATE TRIGGER activate_chats AFTER INSERT ON api.message FOR EACH ROW EXECUTE FUNCTION private.activate_chat();


--
-- Name: conversation broadcast_conversation_events; Type: TRIGGER; Schema: api; Owner: postgres
--

CREATE TRIGGER broadcast_conversation_events AFTER DELETE OR UPDATE ON api.conversation FOR EACH ROW EXECUTE FUNCTION private.broadcast_conversation_events();


--
-- Name: message broadcast_message_events; Type: TRIGGER; Schema: api; Owner: postgres
--

CREATE TRIGGER broadcast_message_events AFTER INSERT OR DELETE OR UPDATE ON api.message FOR EACH ROW EXECUTE FUNCTION private.broadcast_message_events();


--
-- Name: participant enforce_admin_presence; Type: TRIGGER; Schema: api; Owner: postgres
--

CREATE TRIGGER enforce_admin_presence BEFORE DELETE ON api.participant FOR EACH ROW EXECUTE FUNCTION private.prevent_last_admin_leave();


--
-- Name: message enforce_message_blocks; Type: TRIGGER; Schema: api; Owner: postgres
--

CREATE TRIGGER enforce_message_blocks BEFORE INSERT ON api.message FOR EACH ROW EXECUTE FUNCTION private.prevent_blocked_message();


--
-- Name: block block_blocked_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.block
    ADD CONSTRAINT block_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES api.profile(id) ON DELETE CASCADE;


--
-- Name: block block_blocker_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.block
    ADD CONSTRAINT block_blocker_id_fkey FOREIGN KEY (blocker_id) REFERENCES api.profile(id) ON DELETE CASCADE;


--
-- Name: message message_conversation_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.message
    ADD CONSTRAINT message_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES api.conversation(id) ON DELETE CASCADE;


--
-- Name: message message_sender_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.message
    ADD CONSTRAINT message_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES api.profile(id) ON DELETE CASCADE;


--
-- Name: participant participant_conversation_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.participant
    ADD CONSTRAINT participant_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES api.conversation(id) ON DELETE CASCADE;


--
-- Name: participant participant_profile_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.participant
    ADD CONSTRAINT participant_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES api.profile(id) ON DELETE CASCADE;


--
-- Name: profile profile_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: postgres
--

ALTER TABLE ONLY api.profile
    ADD CONSTRAINT profile_id_fkey FOREIGN KEY (id) REFERENCES private.account(id) ON DELETE CASCADE;


--
-- Name: block Blocker can block to add into his blocked list; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Blocker can block to add into his blocked list" ON api.block FOR INSERT TO authenticated_user WITH CHECK ((blocker_id = api.auth_profile_id()));


--
-- Name: block Blocker can see his blocked list; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Blocker can see his blocked list" ON api.block FOR SELECT TO authenticated_user USING ((blocker_id = api.auth_profile_id()));


--
-- Name: block Blocker can unblock from his blocked list; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Blocker can unblock from his blocked list" ON api.block FOR DELETE TO authenticated_user USING ((blocker_id = api.auth_profile_id()));


--
-- Name: participant Only admins can add new members; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Only admins can add new members" ON api.participant FOR INSERT TO authenticated_user WITH CHECK (private.is_admin_of(conversation_id));


--
-- Name: participant Only admins can remove any member; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Only admins can remove any member" ON api.participant FOR DELETE TO authenticated_user USING (private.is_admin_of(conversation_id));


--
-- Name: participant Only admins can turn a member into admin; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Only admins can turn a member into admin" ON api.participant FOR UPDATE TO authenticated_user USING (private.is_admin_of(conversation_id));


--
-- Name: conversation Only admins can update group chat name and avatar; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Only admins can update group chat name and avatar" ON api.conversation FOR UPDATE TO authenticated_user USING (((type = 'group'::text) AND private.is_admin_of(id)));


--
-- Name: message Users can only delete message on their own conversations; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Users can only delete message on their own conversations" ON api.message FOR DELETE TO authenticated_user USING ((sender_id = api.auth_profile_id()));


--
-- Name: message Users can only insert message on their own conversations; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Users can only insert message on their own conversations" ON api.message FOR INSERT TO authenticated_user WITH CHECK (((sender_id = api.auth_profile_id()) AND (conversation_id IN ( SELECT private.get_my_conversation_ids() AS get_my_conversation_ids))));


--
-- Name: conversation Users can only see their own conversations; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Users can only see their own conversations" ON api.conversation FOR SELECT TO authenticated_user USING ((id IN ( SELECT private.get_my_conversation_ids() AS get_my_conversation_ids)));


--
-- Name: message Users can only see their own messages; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Users can only see their own messages" ON api.message FOR SELECT TO authenticated_user USING ((conversation_id IN ( SELECT private.get_my_conversation_ids() AS get_my_conversation_ids)));


--
-- Name: participant Users can only see their own participations; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Users can only see their own participations" ON api.participant FOR SELECT TO authenticated_user USING ((conversation_id IN ( SELECT private.get_my_conversation_ids() AS get_my_conversation_ids)));


--
-- Name: message Users can only update message on their own conversations; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Users can only update message on their own conversations" ON api.message FOR UPDATE TO authenticated_user USING ((sender_id = api.auth_profile_id()));


--
-- Name: profile Users can only update their own profile; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Users can only update their own profile" ON api.profile FOR UPDATE TO authenticated_user USING ((id = api.auth_profile_id()));


--
-- Name: profile Users can view everyone's profiles; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Users can view everyone's profiles" ON api.profile FOR SELECT TO authenticated_user USING (true);


--
-- Name: participant Users can voluntarily leave a chat; Type: POLICY; Schema: api; Owner: postgres
--

CREATE POLICY "Users can voluntarily leave a chat" ON api.participant FOR DELETE TO authenticated_user USING ((profile_id = api.auth_profile_id()));


--
-- Name: block; Type: ROW SECURITY; Schema: api; Owner: postgres
--

ALTER TABLE api.block ENABLE ROW LEVEL SECURITY;

--
-- Name: conversation; Type: ROW SECURITY; Schema: api; Owner: postgres
--

ALTER TABLE api.conversation ENABLE ROW LEVEL SECURITY;

--
-- Name: message; Type: ROW SECURITY; Schema: api; Owner: postgres
--

ALTER TABLE api.message ENABLE ROW LEVEL SECURITY;

--
-- Name: participant; Type: ROW SECURITY; Schema: api; Owner: postgres
--

ALTER TABLE api.participant ENABLE ROW LEVEL SECURITY;

--
-- Name: profile; Type: ROW SECURITY; Schema: api; Owner: postgres
--

ALTER TABLE api.profile ENABLE ROW LEVEL SECURITY;

--
-- Name: account Users can only delete their own account; Type: POLICY; Schema: private; Owner: postgres
--

CREATE POLICY "Users can only delete their own account" ON private.account FOR DELETE TO authenticated_user USING ((id = api.auth_profile_id()));


--
-- Name: account Users can only update their own account; Type: POLICY; Schema: private; Owner: postgres
--

CREATE POLICY "Users can only update their own account" ON private.account FOR UPDATE TO authenticated_user USING ((id = api.auth_profile_id()));


--
-- Name: account Users can only view their own account; Type: POLICY; Schema: private; Owner: postgres
--

CREATE POLICY "Users can only view their own account" ON private.account FOR SELECT TO authenticated_user USING ((id = api.auth_profile_id()));


--
-- Name: account; Type: ROW SECURITY; Schema: private; Owner: postgres
--

ALTER TABLE private.account ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA api TO web_anon;
GRANT USAGE ON SCHEMA api TO authenticated_user;


--
-- Name: SCHEMA private; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA private TO authenticated_user;


--
-- Name: FUNCTION authenticate(_email text, _password text); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.authenticate(_email text, _password text) TO web_anon;


--
-- Name: FUNCTION change_password(_new_password text); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.change_password(_new_password text) TO authenticated_user;


--
-- Name: FUNCTION create_chat(target_profile_id uuid); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.create_chat(target_profile_id uuid) TO authenticated_user;


--
-- Name: FUNCTION create_group_chat(_name text, target_profile_ids uuid[]); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.create_group_chat(_name text, target_profile_ids uuid[]) TO authenticated_user;


--
-- Name: FUNCTION hide_chat(target_conv_id uuid); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.hide_chat(target_conv_id uuid) TO authenticated_user;


--
-- Name: TABLE profile; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.profile TO authenticated_user;


--
-- Name: COLUMN profile.display_name; Type: ACL; Schema: api; Owner: postgres
--

GRANT UPDATE(display_name) ON TABLE api.profile TO authenticated_user;


--
-- Name: COLUMN profile.avatar_url; Type: ACL; Schema: api; Owner: postgres
--

GRANT UPDATE(avatar_url) ON TABLE api.profile TO authenticated_user;


--
-- Name: COLUMN profile.last_active; Type: ACL; Schema: api; Owner: postgres
--

GRANT UPDATE(last_active) ON TABLE api.profile TO authenticated_user;


--
-- Name: FUNCTION register_account(_email text, _password text, _display_name text); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.register_account(_email text, _password text, _display_name text) TO web_anon;


--
-- Name: FUNCTION unarchive_chat(target_conv_id uuid); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.unarchive_chat(target_conv_id uuid) TO authenticated_user;


--
-- Name: TABLE conversation; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.conversation TO authenticated_user;


--
-- Name: COLUMN conversation.name; Type: ACL; Schema: api; Owner: postgres
--

GRANT UPDATE(name) ON TABLE api.conversation TO authenticated_user;


--
-- Name: COLUMN conversation.avatar_url; Type: ACL; Schema: api; Owner: postgres
--

GRANT UPDATE(avatar_url) ON TABLE api.conversation TO authenticated_user;


--
-- Name: TABLE message; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT,DELETE ON TABLE api.message TO authenticated_user;


--
-- Name: COLUMN message.conversation_id; Type: ACL; Schema: api; Owner: postgres
--

GRANT INSERT(conversation_id) ON TABLE api.message TO authenticated_user;


--
-- Name: COLUMN message.content; Type: ACL; Schema: api; Owner: postgres
--

GRANT INSERT(content),UPDATE(content) ON TABLE api.message TO authenticated_user;


--
-- Name: TABLE participant; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT,INSERT,DELETE ON TABLE api.participant TO authenticated_user;


--
-- Name: COLUMN participant.role; Type: ACL; Schema: api; Owner: postgres
--

GRANT UPDATE(role) ON TABLE api.participant TO authenticated_user;


--
-- Name: TABLE archive; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.archive TO authenticated_user;


--
-- Name: TABLE block; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT,INSERT,DELETE ON TABLE api.block TO authenticated_user;


--
-- Name: TABLE inbox; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.inbox TO authenticated_user;


--
-- Name: TABLE account; Type: ACL; Schema: private; Owner: postgres
--

GRANT SELECT,DELETE,UPDATE ON TABLE private.account TO authenticated_user;


--
-- Name: TABLE my_account; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT,DELETE,UPDATE ON TABLE api.my_account TO authenticated_user;


--
-- PostgreSQL database dump complete
--

\unrestrict GbdC27QJI970kGs39aef8faUVKock4NfbhwOfkQDl22d68yP7cqOJ97IdBsjf22

