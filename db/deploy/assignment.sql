-- Deploy personnel:assignment to pg

begin;

create table public.assignment (
  id          serial primary key,
  unit_id     integer not null references public.unit(id),
  user_id     integer not null references public.user(id),
  position_id integer not null references public.position(id)
);

commit;
