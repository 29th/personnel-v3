-- Verify personnel:event on pg

begin;

select id, unit_id, name
from personnel.event
where false;

rollback;
