-- this is the /hide_chat endpoint which is called when a user would want to 'delete'
-- any of his chats. I dont really delete it, just merely hide it.
-- otherwise my database schema design will vomit if I really delete it

create or replace function api.hide_chat(target_conv_id uuid)
returns void
language plpgsql security definer as $$
begin
    update api.participant
    set status = 'hidden'
    where conversation_id = target_conv_id
      and profile_id = api.auth_profile_id();
end;
$$;
