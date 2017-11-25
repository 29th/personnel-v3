-- Revert personnel:user from pg

begin;

drop table personnel.user;

commit;
