create or replace function api.render_chat(_c_id uuid) 
returns text 
language plpgsql as $$
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
        .chat-window { display: flex; flex-direction: column; height: 100%; width: 100%; background: var(--bg-dark); }
        .chat-header { padding: 1rem 1.5rem; border-bottom: 1px solid var(--border); background: var(--surface); display: flex; align-items: center; }
        .chat-messages { flex-grow: 1; overflow-y: auto; padding: 1.5rem; display: flex; flex-direction: column; gap: 1rem; }
        
        /* Message Bubbles */
        .msg { max-width: 70%; padding: 0.75rem 1rem; border-radius: 12px; font-size: 0.95rem; line-height: 1.4; position: relative; }
        .msg-me { align-self: flex-end; background: var(--primary); color: white; border-bottom-right-radius: 2px; }
        .msg-them { align-self: flex-start; background: var(--surface-light); color: var(--text); border-bottom-left-radius: 2px; }
        .msg-time { font-size: 0.7rem; opacity: 0.7; margin-top: 0.4rem; display: block; text-align: right; }

        /* Input Bar */
        .chat-input-area { padding: 1.2rem; border-top: 1px solid var(--border); background: var(--surface); }
        .chat-form { display: flex; gap: 0.8rem; }
        .chat-input { flex-grow: 1; background: var(--bg-dark); border: 1px solid var(--border); border-radius: 6px; padding: 0.75rem 1rem; color: white; outline: none; }
        .chat-input:focus { border-color: var(--primary); }
        .send-btn { background: var(--primary); color: white; border: none; border-radius: 6px; padding: 0 1.2rem; font-weight: 600; cursor: pointer; }
    </style>
    $css$;

    -- 3. Header Construction
    html_output := html_output || format(
        '<div class="chat-window">
            <div class="chat-header">
                <div class="chat-avatar" style="width:32px; height:32px; font-size:0.9rem; margin-right:0.8rem;">%s</div>
                <h3 style="margin:0; font-size:1rem;">%s</h3>
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
                    '<div class="msg %s">
                        %s
                        <span class="msg-time">%s</span>
                    </div>',
                    case when sender_id = api.auth_profile_id() then 'msg-me' else 'msg-them' end,
                    content,
                    to_char(sent_at, 'HH12:MI AM')
                ),
                '' order by sent_at asc
            )
            from api.message
            where conversation_id = _c_id
        ),
        '<div style="text-align:center; color:var(--text-muted); margin-top:2rem;">No messages yet. Send a greeting!</div>'
    );

    -- 5. Input Area Construction
    html_output := html_output || format(
        '</div>
            <div class="chat-input-area">
                <form class="chat-form" 
                      hx-post="/rpc/send_message" 
                      hx-target="#message-list" 
                      hx-swap="beforeend"
                      onsubmit="setTimeout(() => this.reset(), 50)">
                    <input type="hidden" name="_c_id" value="%s">
                    <input type="text" name="_content" class="chat-input" placeholder="Type a message..." required autocomplete="off">
                    <button type="submit" class="send-btn">Send</button>
                </form>
            </div>
        </div>',
        _c_id::text
    );

    return html_output;
end;
$$;