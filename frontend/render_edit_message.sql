-- function to render an inline edit form for a message

create or replace function api.render_edit_message(_msg_id uuid)
returns text
language plpgsql as $$
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
