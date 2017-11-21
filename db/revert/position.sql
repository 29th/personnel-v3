-- Revert personnel:position from pg

begin;

drop table public.position;
drop type access_level;

commit;
