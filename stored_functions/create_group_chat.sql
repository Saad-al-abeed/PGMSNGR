-- this is the /create_group_chat endpoint to create group conversations
-- only group chatting is initialized by this

create or replace function api.create_group_chat(_name text, target_profile_ids uuid[])
returns uuid
language plpgsql security definer as $$
declare
	new_conv_id uuid;
begin
	-- Insert a new row into api.conversation and capture the generated id into new_conv_id
    insert into api.conversation (name, type) values (_name, 'group')
	returning id into new_conv_id;

	-- Insert a row into api.participant using new_conv_id and auth helper function
    insert into api.participant (conversation_id, profile_id, role) values
	(new_conv_id, api.auth_profile_id(), 'admin'); -- creator's id already included here

	-- Insert a row into api.participant using new_conv_id and target_profile_id
    insert into api.participant (conversation_id, profile_id, role) select
	new_conv_id, unnest(target_profile_ids), 'member'
	where unnest(target_profile_ids) <> api.auth_profile_id();
	-- if creator's id also included in the target array, it will now be ignored

    return new_conv_id;
end;
$$;