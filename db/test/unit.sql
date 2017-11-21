-- Test personnel:unit on pg
begin;

create extension if not exists pgtap;

select * from no_plan();

insert into unit (id, abbr, parent_path) values
  (1, 'Bn HQ', 'root'),
  (2, 'Able', 'root.1'),
  (3, 'AP1', 'root.1.2');

select results_eq(
  'select id, abbr, parent_path::text from unit',
  $$ values
    (1, 'Bn HQ', 'root'),
    (2, 'Able', 'root.1'),
    (3, 'AP1', 'root.1.2')
  $$
);

select results_eq(
  $$ select abbr from unit where parent_path <@ 'root.1' $$,
  $$ values ('Able'), ('AP1') $$
);

select * from finish();

rollback;
