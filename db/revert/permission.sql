-- Revert personnel:permission from pg

begin;

drop table personnel.permission;

commit;
