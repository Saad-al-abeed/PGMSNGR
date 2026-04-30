-- trigger for broadcasting message insertion, updation and deletion

create or replace function private.broadcast_message_events()
returns trigger
language plpgsql as $$
declare
    payload jsonb;
begin
    if TG_OP = 'DELETE' then
        payload := jsonb_build_object(
            'event_type', 'DELETE',
            'message_id', OLD.id,
            'conversation_id', OLD.conversation_id
        );
        perform pg_notify('chat_stream', payload::text);
        return OLD;
    else
        payload := jsonb_build_object(
            'event_type', TG_OP, -- Will dynamically inject 'INSERT' or 'UPDATE'
            'message_id', NEW.id,
            'conversation_id', NEW.conversation_id,
            'sender_id', NEW.sender_id,
            'content', NEW.content,
            'sent_at', NEW.sent_at
        );
        perform pg_notify('chat_stream', payload::text);
        return NEW;
    end if;
end;
$$;

drop trigger if exists broadcast_message_events on api.message;
create trigger broadcast_message_events
after insert or update or delete on api.message
for each row
execute function private.broadcast_message_events();