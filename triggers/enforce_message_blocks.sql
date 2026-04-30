-- this script prevents DM transactions between blocker and blocked user

create or replace function private.prevent_blocked_message()
returns trigger
language plpgsql security definer as $$
declare
    is_direct boolean;
    other_profile_id uuid;
    block_exists boolean;
begin
    -- check for DMs only
    select type = 'direct' into is_direct
    from api.conversation
    where id = NEW.conversation_id;

    if is_direct then
        -- find the other person in this DM
        select profile_id into other_profile_id
        from api.participant
        where conversation_id = NEW.conversation_id
          and profile_id != NEW.sender_id; -- NEW.sender_id is the sender

        -- Check the block list in both directions
        select exists (
            select 1 from api.block
            where (blocker_id = NEW.sender_id and blocked_id = other_profile_id)
               or (blocker_id = other_profile_id and blocked_id = NEW.sender_id)
        ) into block_exists;

        -- If a block exists, throw error
        if block_exists then
            raise exception 'Message could not be sent.';
        end if;
    end if;

    return NEW;
end;
$$;

drop trigger if exists enforce_message_blocks on api.message;
create trigger enforce_message_blocks
before insert on api.message
for each row
execute function private.prevent_blocked_message();