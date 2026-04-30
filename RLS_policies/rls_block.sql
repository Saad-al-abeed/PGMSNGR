-- creating policies for the block unblock feature

alter table api.block enable row level security;

-- select policy
drop policy if exists "Blocker can see his blocked list" on api.block;
create policy "Blocker can see his blocked list"
on api.block
for select
to authenticated_user
using ( blocker_id = api.auth_profile_id() );

-- insert policy
drop policy if exists "Blocker can block to add into his blocked list" on api.block;
create policy "Blocker can block to add into his blocked list"
on api.block
for insert
to authenticated_user
with check ( blocker_id = api.auth_profile_id() );

-- delete policy
drop policy if exists "Blocker can unblock from his blocked list" on api.block;
create policy "Blocker can unblock from his blocked list"
on api.block
for delete
to authenticated_user
using ( blocker_id = api.auth_profile_id() );