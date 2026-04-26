-- Implementing RLS policies on the api.profile table

alter table api.profile enable row level security;

-- Create the View Policy
create policy "Users can view everyone's profiles"
on api.profile
for select
to authenticated_user
using ( true );

-- Create the Update Policy
create policy "Users can only update their own profile"
on api.profile
for update
to authenticated_user
using ( id = api.auth_profile_id() );

-- Deletion policy not needed
-- Account and profile are cascaded. Account deletion already implemented