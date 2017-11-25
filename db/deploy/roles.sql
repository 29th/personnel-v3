-- Deploy personnel:roles to pg

begin;

create role personnel_anonymous;
grant personnel_anonymous to current_user;

create role personnel_user;
grant personnel_user to current_user;

commit;
