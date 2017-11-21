-- Deploy personnel:permission to pg

begin;

create table public.permission (
  id          serial primary key,
  unit_id     integer not null references public.unit(id),
  access_level  access_level not null,
  ability     text not null check (char_length(ability) < 24)
);

commit;
