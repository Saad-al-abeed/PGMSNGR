-- this is the /authenticate endpoint
-- this script creates a stored function that authenticates a user trying to login
-- successful credentials will return a JWT token that will last 7 days
-- Secret string : thisstringissoverysecretextrachars (Very important)

create or replace function api.authenticate(
	_email text, _password text
) returns api.jwt_token 
language plpgsql security definer as $$
declare
	account_data private.account;
	jwt api.jwt_token;
begin
	select * into account_data from private.account
	where email = _email;

	if account_data.email is null then raise exception 'invalid email or password';
	end if;

	if account_data.password_hash != crypt(_password, account_data.password_hash)
	then raise exception 'invalid email or password'; end if;

	jwt.token := sign(json_build_object(
		'role', account_data.role,
		'profile_id', account_data.id,
		'token_version', account_data.token_version,
		'exp', extract(epoch from now() + interval '7 days')), 'thisstringissoverysecretextrachars');

	return jwt;
end;
$$;