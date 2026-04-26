-- helper function to get the authenticated user's profile id to be used for 
-- implementing RLS policies
-- token version checking implemented to prevent old unexpired tokens to be used
-- to make http requests

create or replace function api.auth_profile_id() 
returns uuid 
language plpgsql stable security definer as $$
declare
    _jwt_id uuid := nullif(current_setting('request.jwt.claims', true)::json->>'profile_id', '')::uuid;
    _jwt_version int := (current_setting('request.jwt.claims', true)::json->>'token_version')::int;
    _db_version int;
begin
    if _jwt_id is null or _jwt_version is null then 
        return null;
    end if;

    select token_version into _db_version from private.account where id = _jwt_id;

    if _db_version = _jwt_version then 
        return _jwt_id;
    else 
        return null;
    end if;
end;
$$;