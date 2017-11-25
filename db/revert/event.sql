-- Revert personnel:event from pg

begin;

drop table personnel.event;

commit;
