-- Revert personnel:unit from pg

begin;

drop table personnel.unit;

commit;
