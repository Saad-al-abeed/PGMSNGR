-- this script renders inbox on the left side of the application page

create or replace function api.render_inbox() 
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
            display: flex; align-items: center; padding: 1rem;
            border-bottom: 1px solid var(--border); cursor: pointer;
            transition: background 0.2s;
        }
        .chat-card:hover { background: var(--surface-light); }
        .chat-card.active { 
            background: #1f2937; 
            border-left: 3px solid var(--primary); 
            padding-left: calc(1rem - 3px); 
        }
        .chat-avatar {
            width: 44px; height: 44px; border-radius: 50%;
            background: var(--primary); color: white;
            display: flex; justify-content: center; align-items: center;
            font-weight: bold; font-size: 1.2rem; margin-right: 1rem;
            flex-shrink: 0; text-transform: uppercase;
        }
        .chat-info { flex-grow: 1; overflow: hidden; }
        .chat-name { 
            font-weight: 600; color: var(--text); margin-bottom: 0.25rem; 
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; 
        }
        .chat-preview { 
            font-size: 0.85rem; color: var(--text-muted); 
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
        '<div style="text-align: center; color: var(--text-muted); padding: 2rem 1rem;">
            You have no active conversations.<br><br>
            <span style="font-size: 2rem;">📭</span>
        </div>'
    );

    return html_output;
end;
$$;