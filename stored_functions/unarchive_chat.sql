-- this is the /unarchive_chat endpoint which is called when a user would want to activate
-- any of his hidden chats after viewing it in his archive endpoint

create or replace function api.unarchive_chat(target_conv_id uuid)
returns void
language plpgsql security definer as $$
begin
    update api.participant
    set status = 'active'
    where conversation_id = target_conv_id
      and profile_id = api.auth_profile_id();
end;
$$;