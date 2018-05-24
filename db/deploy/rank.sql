-- Deploy personnel:rank to pg

begin;

create table personnel.rank (
  id        serial primary key,
  abbr      text not null check (char_length(abbr) < 8),
  name      text check (char_length(name) < 80)
);

grant select on table personnel.rank to personnel_user;

commit;
