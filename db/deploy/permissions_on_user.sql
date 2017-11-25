-- Deploy personnel:permissions_on_user to pg

begin;

create function personnel.permissions_on_user(
  actor_id integer,
  subject_id integer
) returns text[] as $$

select array(
  select distinct unnest(personnel.permissions_on_unit($1, unit.id))
  from personnel.assignment
  inner join personnel.unit on (unit.id = assignment.unit_id)
  where assignment.user_id = $2
);

$$ language sql stable;

commit;
