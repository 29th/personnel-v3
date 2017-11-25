-- Revert personnel:assignment from pg

begin;

drop table personnel.assignment;

commit;
