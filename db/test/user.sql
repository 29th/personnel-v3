-- Test personnel:user on pg

begin;

create extension if not exists pgtap;

select plan(2);

select has_table('user');
select has_column('user', 'id');

select * from finish();

rollback;
