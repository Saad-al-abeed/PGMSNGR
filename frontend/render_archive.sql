-- this script renders archived chats on the left side of the application page

create or replace function api.render_archive() 
returns text 
language plpgsql as $$
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
$$;
