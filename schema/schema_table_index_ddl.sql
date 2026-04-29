-- Here the schemas and the tables are going to be defined

-- schema creation
drop schema if exists private cascade;
create schema private;

drop schema if exists api cascade;
create schema api;

-- table creation
create table private.account(
	id uuid primary key default gen_random_uuid(),
	email text not null unique,
	password_hash text not null,
	role name default 'authenticated_user'
);

alter table private.account
add column token_version int default 1;

create table api.profile(
	id uuid primary key references private.account(id) on delete cascade,
	display_name text,
	avatar_url text,
	last_active timestamptz
);

create table api.conversation(
	id uuid primary key default gen_random_uuid(),
	type text check (type = 'direct' or type = 'group'),
	created_at timestamptz default now()
);

alter table api.conversation 
add column name text; -- this column is for naming the group conversations

alter table api.conversation
add column avatar_url text; -- this column is for giving an avatar for group chats

create table api.participant(
	conversation_id uuid references api.conversation(id) on delete cascade,
	profile_id uuid references api.profile(id) on delete cascade,
	joined_at timestamptz default now(),
	role text check (role = 'member' or role = 'admin'),
	primary key (conversation_id, profile_id)
);

alter table api.participant 
add column status text not null default 'active' 
check (status in ('active', 'hidden')); -- this column is for giving the 'delete' chat feature

create table api.message(
	id uuid primary key default gen_random_uuid(),
	conversation_id uuid references api.conversation(id) on delete cascade,
	sender_id uuid references api.profile(id) on delete cascade,
	content text not null,
	sent_at timestamptz default now()
);

alter table api.message alter column
sender_id set default api.auth_profile_id();

-- index creation
create index participant_profile_idx on api.participant(profile_id);

create index message_sender_idx on api.message(sender_id);

-- composite index for chat room optimization
create index message_time_idx on api.message(conversation_id, sent_at desc);