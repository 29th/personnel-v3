-- Verify personnel:assignment on pg

begin;

select id, unit_id, user_id, position_id
from assignment
where false;

rollback;
