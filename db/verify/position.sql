-- Verify personnel:position on pg

begin;

select id, name, access_level
from public.position
where false;

select 1/count(*) -- fails if dividing by 0
from pg_type
where typname = 'access_level';

rollback;
