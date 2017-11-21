-- Revert personnel:check-permission from pg

begin;

drop function public.permissions_on_unit(integer, integer);

commit;
