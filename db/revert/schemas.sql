-- Revert personnel:schemas from pg

begin;

drop schema personnel;

commit;
