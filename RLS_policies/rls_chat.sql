-- makings policies for the chat system

-- enabling row level security on the required tables

alter table api.conversation enable row level security;
alter table api.participant enable row level security;
alter table api.message enable row level security;

-- drop policy "Users can only see their own participations" on api.participant;
-- drop policy "Users can only see their own messages" on api.message;
-- drop policy "Users can only see their own conversations" on api.conversation;
-- drop policy "Users can only insert message on their own conversations" on api.message;

-- create the select policies
create policy "Users can only see their own participations"
on api.participant
for select 
to authenticated_user
using ( conversation_id in (select private.get_my_conversation_ids()) );

create policy "Users can only see their own messages"
on api.message
for select 
to authenticated_user
using ( conversation_id in (select private.get_my_conversation_ids()) );

create policy "Users can only see their own conversations"
on api.conversation
for select
to authenticated_user
using ( id in (select private.get_my_conversation_ids()) );

-- create the insert policies
create policy "Users can only insert message on their own conversations"
on api.message
for insert
to authenticated_user
with check ( sender_id = api.auth_profile_id() and 
	conversation_id in (select private.get_my_conversation_ids())
);

-- create the delete policies
create policy "Users can only delete message on their own conversations"
on api.message
for delete
to authenticated_user
using ( sender_id = api.auth_profile_id() );

-- create the update policies
create policy "Users can only update message on their own conversations"
on api.message
for update
to authenticated_user
using ( sender_id = api.auth_profile_id() );