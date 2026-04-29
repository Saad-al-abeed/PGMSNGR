-- creating a trigger to reactivate the hidden chat if any other user sends him a message

create or replace function private.activate_chat()
returns trigger
language plpgsql security definer as $$
begin
    -- If a new message arrives, set everyone in the room back to active
    update api.participant set status = 'active'
    where conversation_id = NEW.conversation_id and status = 'hidden';
    return NEW;
end;
$$;

create trigger activate_chats
after insert on api.message
for each row
execute function private.activate_chat();