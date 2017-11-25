-- Deploy personnel:permission to pg

begin;

create table personnel.permission (
  id          serial primary key,
  unit_id     integer not null references personnel.unit(id),
  access_level  personnel.access_level not null,
  ability     text not null check (char_length(ability) < 24)
);

grant select on table personnel.permission to personnel_user;

commit;
