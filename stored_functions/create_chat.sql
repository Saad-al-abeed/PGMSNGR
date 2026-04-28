-- this is the /create_chat endpoint to create conversations for chatting
-- for now only direct chatting is done by this

create or replace function api.create_chat(target_profile_id uuid) 
returns uuid 
language plpgsql security definer as $$
declare
    new_conv_id uuid;
begin
    -- Insert a new row into api.conversation and capture the generated id into new_conv_id
    insert into api.conversation (type) values ('direct')
	returning id into new_conv_id;

    -- Insert a row into api.participant using new_conv_id and your auth helper function
    insert into api.participant (conversation_id, profile_id, role) values
	(new_conv_id, api.auth_profile_id(), 'member');

    -- Insert a row into api.participant using new_conv_id and target_profile_id
    insert into api.participant (conversation_id, profile_id, role) values
	(new_conv_id, target_profile_id, 'member');

    return new_conv_id;
end;
$$;