-- Deploy personnel:permissions_on_user to pg

begin;

create function public.permissions_on_user(
  actor_id integer,
  subject_id integer
) returns text[] as $$

select array(
  select distinct unnest(permissions_on_unit($1, unit.id))
  from assignment
  inner join unit on (unit.id = assignment.unit_id)
  where assignment.user_id = $2
);

$$ language sql stable;

commit;
