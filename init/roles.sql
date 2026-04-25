-- creating roles for using the api

-- creating anonymous web user with 0 priviledges just to register and login to the application
drop role if exists web_anon;
create role web_anon nologin;
grant usage on schema api to web_anon;
grant execute on function api.register_account, api.authenticate, api.index to web_anon;

-- creating authenticated users after successful login to the application
drop role if exists authenticated_user;
create role authenticated_user nologin;
grant usage on schema api to authenticated_user;

-- creating an authenticator which postgrest will use
drop role if exists authenticator;
create role authenticator with password '1234' login;
grant web_anon, authenticated_user to authenticator;