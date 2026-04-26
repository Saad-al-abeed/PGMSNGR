-- creating a view to access the account table from the private schema
-- authenticated_user will only see his own account because RLS is implemented
drop view if exists api.my_account;
create or replace view api.my_account with (security_invoker = true) as
select email -- aint letting anyone tamper with id, password_hash and role
from private.account;

-- Granting CRUD permissions
grant select on api.my_account to authenticated_user;
grant update on api.my_account to authenticated_user;
grant delete on api.my_account to authenticated_user;