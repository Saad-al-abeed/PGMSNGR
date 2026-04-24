-- creating a jwt_token data type for verification
create type api.jwt_token as (
  token text
);