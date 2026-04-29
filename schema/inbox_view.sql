-- creating the /inbox endpoint which returns current ACTIVE chats in the inbox

create or replace view api.inbox as
select 
    c.id as conversation_id,
    c.type as conversation_type,
    
    -- If it's a group, use c.name. If direct, use the other person's name.
    coalesce(c.name, other_profile.display_name) as chat_name,
    coalesce(c.avatar_url, other_profile.avatar_url) as chat_avatar,
    
    last_msg.content as last_message_content,
    last_msg.sent_at as last_message_at
    
from api.participant my_p
join api.conversation c on my_p.conversation_id = c.id

-- Only search for the "other" participant if this is a direct chat
left join api.participant other_p 
    on c.type = 'direct' 
    and other_p.conversation_id = c.id 
    and other_p.profile_id != my_p.profile_id
left join api.profile other_profile 
    on other_p.profile_id = other_profile.id

-- For every conversation row, grab exactly the 1 newest message
left join lateral (
    select content, sent_at
    from api.message m
    where m.conversation_id = c.id
    order by sent_at desc
    limit 1
) last_msg on true

where my_p.profile_id = api.auth_profile_id() and my_p.status = 'active';

-- grant permission to select this view
grant select on api.inbox to authenticated_user;