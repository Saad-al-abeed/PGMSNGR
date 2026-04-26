-- this script creates an endpoint /change_password to change the password safely 

create or replace function api.change_password(
	_new_password text
) returns void 
language sql security definer as $$
	update private.account set
	password_hash = crypt(_new_password, gen_salt('bf')),
	token_version = token_version + 1
	where id = api.auth_profile_id(); -- manual security because RLS aint gonna work here
$$;

-- successful execution of this function should return
-- status code 204 no content