-- Verify personnel:check-permission on pg

begin;

select has_function_privilege(
  'public.permissions_on_unit(integer, integer)',
  'execute'
);

rollback;
