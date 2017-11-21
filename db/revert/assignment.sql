-- Revert personnel:assignment from pg

begin;

drop table public.assignment;

commit;
