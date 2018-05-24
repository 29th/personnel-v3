-- Verify personnel:rank on pg

begin;

select id, abbr, name
from personnel.rank
where false;

rollback;
