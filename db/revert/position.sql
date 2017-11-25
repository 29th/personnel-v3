-- Revert personnel:position from pg

begin;

drop table personnel.position;
drop type personnel.access_level;

commit;
