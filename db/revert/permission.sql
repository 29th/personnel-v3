-- Revert personnel:permission from pg

begin;

drop table public.permission;

commit;
