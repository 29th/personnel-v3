-- Verify personnel:user on pg

begin;

select id, first_name, last_name
from personnel.user
where false;

rollback;
