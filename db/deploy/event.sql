-- Deploy personnel:event to pg

begin;

create table personnel.event (
  id          serial primary key,
  unit_id     integer not null references personnel.unit(id),
  name        text
  -- start_date  timestamp not null,
  -- end_date    timestamp not null
);

grant select, insert on table personnel.event to personnel_user;
grant usage on sequence personnel.event_id_seq to personnel_user;

alter table personnel.event enable row level security;

create policy select_event on personnel.event for select
  using ('view_event' = any(personnel.permissions_on_unit(current_setting('jwt.claims.user_id', true)::integer, unit_id)));

create policy insert_event on personnel.event for insert
  with check ('add_event' = any(personnel.permissions_on_unit(current_setting('jwt.claims.user_id', true)::integer, unit_id)));

commit;
