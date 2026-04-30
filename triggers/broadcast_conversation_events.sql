-- trigger for broadcasting group chat metadata updation and group chat deletion

create or replace function private.broadcast_conversation_events()
returns trigger
language plpgsql as $$
declare
    payload jsonb;
begin
    if TG_OP = 'DELETE' then
        payload := jsonb_build_object(
            'event_type', 'DELETE',
            'conversation_id', OLD.id
        );
        perform pg_notify('conversation_stream', payload::text);
        return OLD;
        
    elsif TG_OP = 'UPDATE' then
        payload := jsonb_build_object(
            'event_type', TG_OP,
            'conversation_id', NEW.id,
            'name', NEW.name,
            'avatar_url', NEW.avatar_url
        );
        perform pg_notify('conversation_stream', payload::text);
        return NEW;
    end if;
    
    return null;
end;
$$;


drop trigger if exists broadcast_conversation_events on api.conversation;
create trigger broadcast_conversation_events
after update or delete on api.conversation
for each row
execute function private.broadcast_conversation_events();