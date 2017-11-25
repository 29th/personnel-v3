-- Revert personnel:check-permission from pg

begin;

drop function personnel.permissions_on_unit(integer, integer);

commit;
