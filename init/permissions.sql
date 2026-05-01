-- permission granting script

-- web-anon permissions
grant usage on schema api to web_anon;
grant execute on function api.register_account, api.authenticate, api.index to web_anon;

-- authenticated_user permissions
grant usage on schema api, private to authenticated_user;
grant select on private.account to authenticated_user;
grant update on private.account to authenticated_user;
grant delete on private.account to authenticated_user;
grant execute on function api.change_password to authenticated_user;
grant select on api.profile to authenticated_user;
grant update (display_name, avatar_url, last_active) on api.profile to authenticated_user;
grant select on api.participant to authenticated_user;
grant insert on api.participant to authenticated_user;
grant delete on api.participant to authenticated_user;
grant update (role) on api.participant to authenticated_user;
grant select on api.conversation to authenticated_user;
grant update (name, avatar_url) on api.conversation to authenticated_user;
grant select on api.message to authenticated_user;
grant insert (conversation_id, content) on api.message to authenticated_user;
grant update (content) on api.message to authenticated_user;
grant delete on api.message to authenticated_user;
grant execute on function api.create_chat to authenticated_user;
grant execute on function api.create_group_chat to authenticated_user;
grant execute on function api.hide_chat to authenticated_user;
grant execute on function api.unarchive_chat to authenticated_user;
grant select, insert, delete on api.block to authenticated_user;

