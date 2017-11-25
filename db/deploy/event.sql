-- Deploy personnel:event to pg

begin;

create table personnel.event (
  id          serial primary key,
  unit_id     integer not null references personnel.unit(id),
  name        text
  -- start_date  timestamp not null,
  -- end_date    timestamp not null
);

grant select on table personnel.event to personnel_user;

alter table personnel.event enable row level security;

create policy select_event on personnel.event for select
  using ('view_event' = any(personnel.permissions_on_unit(current_setting('jwt.claims.user_id', true)::integer, unit_id)));

commit;
