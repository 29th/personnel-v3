-- Verify personnel:user on pg

begin;

select id, first_name, last_name
from public.user
where false;

rollback;
