create or replace function api.render_user_directory() 
returns text 
language plpgsql as $$
declare
    html_output text;
begin
    -- Force PostgREST to return raw HTML
    perform set_config('response.headers', '[{"Content-Type": "text/html"}]', true);

    -- Base container styling (reusing your settings CSS for consistency)
    html_output := '<div class="settings-container" style="animation: fadeIn 0.3s ease;">
                        <div class="settings-header">
                            <h2>Start a New Chat</h2>
                            <p style="color: #94a3b8; margin-top: 0.5rem;">Select a user to initiate end-to-end encryption.</p>
                        </div>
                        <div class="settings-grid" style="grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1rem;">';

    -- Query profiles and build clickable cards
    html_output := html_output || coalesce(
        (
            select string_agg(
                format(
                    '<div class="chat-card" style="background: rgba(15, 23, 42, 0.6); border: 1px solid rgba(255,255,255,0.05); border-radius: 12px; cursor: pointer;"
                          hx-post="/rpc/create_chat"
                          hx-vals=''{"target_profile_id": "%s"}'' 
                          hx-swap="none"
                          hx-on::after-request="if(event.detail.successful) {
                              const resp = JSON.parse(event.detail.xhr.response);
                              /* PostgREST might return the raw UUID string, an object, or an array depending on your function */
                              const newConvId = typeof resp === ''string'' ? resp : (Array.isArray(resp) ? resp[0].id : resp.id);
                              
                              /* Instantly switch the UI to the newly created chat */
                              htmx.ajax(''POST'', ''/rpc/render_chat'', { 
                                  target: ''#chat-container'', 
                                  values: { _c_id: newConvId } 
                              });
                              
                              /* Refresh the inbox so the new chat appears on the left */
                              htmx.trigger(''#inbox-container'', ''load'');
                          }">
                        <div class="chat-avatar" style="box-shadow: none;">%s</div>
                        <div class="chat-info">
                            <div class="chat-name">%s</div>
                            <div class="chat-preview">Click to connect</div>
                        </div>
                    </div>',
                    p.id::text,
                    left(p.display_name, 1),
                    replace(replace(p.display_name, '&', '&amp;'), '<', '&lt;')
                ),
                ''
            )
            from api.profile p
            where p.id != api.auth_profile_id()
            and not exists (
                -- Only exclude if you already have a DIRECT conversation with them
                select 1
                from api.participant my_p
                join api.participant their_p on my_p.conversation_id = their_p.conversation_id
                join api.conversation c on c.id = my_p.conversation_id
                where my_p.profile_id = api.auth_profile_id()
                  and their_p.profile_id = p.id
                  and c.type = 'direct' 
            )
        ),
        '<div style="grid-column: 1 / -1; text-align: center; color: #94a3b8; padding: 4rem 1rem;">
            <div style="font-size: 3rem; margin-bottom: 1rem; opacity: 0.5;">🔍</div>
            No new users found. You are already chatting with everyone!
        </div>'
    );

    html_output := html_output || '</div></div>';
    return html_output;
end;
$$;