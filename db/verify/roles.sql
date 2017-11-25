-- Verify personnel:roles on pg

begin;

select 1/count(*) -- fails if dividing by 0
from pg_roles
where rolname = 'personnel_anonymous';

select 1/count(*) -- fails if dividing by 0
from pg_roles
where rolname = 'personnel_user';

rollback;
