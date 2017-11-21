-- Revert personnel:user from pg

begin;

drop table public.user;

commit;
