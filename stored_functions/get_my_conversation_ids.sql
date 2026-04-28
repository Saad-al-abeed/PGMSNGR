-- helper function to get the uuids of a user's conversations

create or replace function private.get_my_conversation_ids()
returns setof uuid
language sql security definer stable as $$
    select conversation_id 
    from api.participant 
    where profile_id = api.auth_profile_id();
$$;