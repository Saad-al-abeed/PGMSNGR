-- this is the /register_account endpoint
-- this script creates a stored function that will take the email, password and display_name
-- from the user and create an account and profile for him in the respective tables

create or replace function api.register_account(
	_email text, _password text, _display_name text
) returns api.profile 
language plpgsql security definer as $$ 
declare
	new_account_id uuid;
	new_profile api.profile;
begin
	-- inserting new account
	insert into private.account (email, password_hash) values
	(_email, crypt(_password, gen_salt('bf'))) 
	returning id into new_account_id;

	-- inserting new profile
	insert into api.profile (id, display_name, avatar_url, last_active) values
	(new_account_id, _display_name, '', now())
	returning * into new_profile;

	-- returning the new profile data
	return new_profile;
end;
$$;