-- this is the /create_chat endpoint to create conversations for chatting
-- only direct chatting is initialized by this

create or replace function api.create_chat(target_profile_id uuid) 
returns uuid 
language plpgsql security definer as $$
declare
    existing_conv_id uuid;
    new_conv_id uuid;
begin
    -- Prevent users from trying to DM themselves
    if target_profile_id = api.auth_profile_id() then
        raise exception 'You cannot create a direct message with yourself.';
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