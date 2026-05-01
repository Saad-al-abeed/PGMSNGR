-- function to fetch and render a single message bubble as HTML

create or replace function api.render_message_bubble(_msg_id uuid)
returns text
language plpgsql as $$
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
