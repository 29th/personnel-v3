-- Deploy personnel:check-permission to pg

begin;

create function personnel.permissions_on_unit(
  actor_id integer,
  unit_id  integer
) returns text[] as $$

select array(
  select permission.ability
  from personnel.assignment
  inner join personnel.unit on (unit.id = assignment.unit_id)
  inner join personnel.position on (position.id = assignment.position_id)
  inner join personnel.permission on (
    permission.unit_id = assignment.unit_id
    and permission.access_level <= position.access_level
  )
  where assignment.user_id = $1
  and (
    unit.id = $2
    or unit.parent_path @> (
      select parent_path from personnel.unit where id = $2
    )
  )
);

$$ language sql stable;

commit;
