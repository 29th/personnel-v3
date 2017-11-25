-- Deploy personnel:assignment to pg

begin;

create table personnel.assignment (
  id          serial primary key,
  unit_id     integer not null references personnel.unit(id),
  user_id     integer not null references personnel.user(id),
  position_id integer not null references personnel.position(id)
);

commit;
