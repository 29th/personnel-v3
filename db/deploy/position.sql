-- Deploy personnel:position to pg

begin;

create type personnel.access_level as enum (
  'member',
  'clerk',
  'leader'
);

create table personnel.position (
  id            serial primary key,
  name          text check (char_length(name) < 80),
  access_level  personnel.access_level default 'member'
);

grant select on table personnel.position to personnel_user;

commit;
