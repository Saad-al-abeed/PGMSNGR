-- helper function to know whether the user is admin or not to safeguard from infinite 
-- recursion loop

create or replace function private.is_admin_of(target_conv_id uuid)
returns boolean
language sql security definer stable as $$
    select exists (
        select 1 
        from api.participant
        where conversation_id = target_conv_id
        and profile_id = api.auth_profile_id()
        and role = 'admin'
    );
$$;