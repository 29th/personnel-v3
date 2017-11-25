-- Revert personnel:roles from pg

begin;

drop role personnel_anonymous;
drop role personnel_user;

commit;
