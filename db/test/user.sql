-- Test personnel:user on pg

set client_min_messages to warning; -- disable warning from create extension
create extension if not exists pgtap;
reset client_min_messages;

begin;
select plan(2);

select has_table('user');
select has_column('user', 'id');

select * from finish();
rollback;
