-- Implementing RLS policies on the private.account table

alter table private.account enable row level security;

-- Create the View Policy
create policy "Users can only view their own account"
on private.account
for select
to authenticated_user
using ( id = api.auth_profile_id() );

-- Create the Update Policy
create policy "Users can only update their own account"
on private.account
for update
to authenticated_user
using ( id = api.auth_profile_id() );

-- Create the Delete Policy
create policy "Users can only delete their own account"
on private.account
for delete
to authenticated_user
using ( id = api.auth_profile_id() );