-- Verify personnel:schemas on pg

begin;

select pg_catalog.has_schema_privilege('personnel', 'usage');

rollback;
