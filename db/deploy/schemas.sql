-- Deploy personnel:schemas to pg

begin;

create schema personnel;

grant usage on schema personnel to personnel_anonymous, personnel_user;

commit;
