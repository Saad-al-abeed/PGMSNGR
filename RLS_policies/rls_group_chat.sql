-- defining the row level securities for the group chat feature

drop policy if exists "Only admins can add new members" on api.participant;
drop policy if exists "Only admins can remove any member" on api.participant;
drop policy if exists "Only admins can turn a member into admin" on api.participant;
drop policy if exists "Users can voluntarily leave a chat" on api.participant;

-- Add members policy
create policy "Only admins can add new members"
on api.participant
for insert
to authenticated_user
with check ( private.is_admin_of(conversation_id) );

-- Kick members policy
create policy "Only admins can remove any member"
on api.participant
for delete
to authenticated_user
using ( private.is_admin_of(conversation_id) );

-- Upgrade a member to admin policy
create policy "Only admins can turn a member into admin"
on api.participant
for update
to authenticated_user
using ( private.is_admin_of(conversation_id) );

-- Self leave policy
create policy "Users can voluntarily leave a chat"
on api.participant
for delete
to authenticated_user
using ( profile_id = api.auth_profile_id() );