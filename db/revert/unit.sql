-- Revert personnel:unit from pg

begin;

drop table public.unit;

commit;
