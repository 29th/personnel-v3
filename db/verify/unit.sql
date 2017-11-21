-- Verify personnel:unit on pg

begin;

select id, name, abbr, parent_path
from public.unit
where false;

select 1/count(*) -- fails if dividing by 0
from pg_extension
where extname = 'ltree';

rollback;
