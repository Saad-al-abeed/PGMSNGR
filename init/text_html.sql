-- creating a custom type for rendering HTML
drop domain if exists "text/html" cascade;
create domain "text/html" as text;