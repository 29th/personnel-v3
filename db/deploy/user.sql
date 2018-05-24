-- Deploy personnel:user to pg

begin;

create table personnel.user (
  id          serial primary key,
  first_name  text not null check (char_length(first_name) < 80),
  last_name   text not null check (char_length(last_name) < 80),
  rank        integer not null references personnel.rank(id)
);

grant select on table personnel.user to personnel_user;

commit;
