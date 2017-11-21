-- Deploy personnel:position to pg

begin;

create type access_level as enum (
  'member',
  'clerk',
  'leader'
);

create table public.position (
  id            serial primary key,
  name          text check (char_length(name) < 80),
  access_level  access_level default 'member'
);

commit;
