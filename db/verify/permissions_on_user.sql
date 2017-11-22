-- Verify personnel:permissions_on_user on pg

begin;

select has_function_privilege(
  'public.permissions_on_user(integer, integer)',
  'execute'
);

rollback;
