-- this script creates a trigger to make sure the last remaining admin does not get to
-- leave a group chat before assigning another admin

create or replace function private.prevent_last_admin_leave()
returns trigger 
language plpgsql as $$
declare
    remaining_admin_count int;
begin
    if OLD.role = 'admin' then
        
        -- Counting other admins
        select count(*) into remaining_admin_count
        from api.participant
        where conversation_id = OLD.conversation_id 
          and role = 'admin' 
          and profile_id != OLD.profile_id; -- Don't count the person leaving

        if remaining_admin_count = 0 then
            raise exception 'You are the last admin. Promote another member to admin before leaving, or delete the group entirely.';
        end if;
    end if;

    return OLD;
end;
$$;

create trigger enforce_admin_presence
before delete on api.participant
for each row 
execute function private.prevent_last_admin_leave();