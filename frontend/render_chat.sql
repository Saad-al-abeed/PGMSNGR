-- this script renders the chat

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
$$;