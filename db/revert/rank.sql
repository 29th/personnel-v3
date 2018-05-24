-- Revert personnel:rank from pg

begin;

drop table personnel.rank;

commit;
