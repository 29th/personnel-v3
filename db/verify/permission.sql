-- Verify personnel:permission on pg

begin;

select id, unit_id, access_level, ability
from public.permission
where false;

rollback;
