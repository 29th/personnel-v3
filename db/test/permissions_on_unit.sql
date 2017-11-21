-- Test personnel:permission on pg

begin;
create extension if not exists pgtap;
select * from no_plan();

insert into public.user (id, first_name, last_name) values
  (1, 'Private', 'Axe'),
  (2, 'Sergeant', 'Bug'),
  (3, 'Lieutenant', 'Cup');

insert into public.unit (id, abbr, parent_path) values
  (1, 'Bn HQ', 'root'),
  (2, 'Able', 'root.1'),
  (3, 'AP1', 'root.1.2'),
  (4, 'AP1S1', 'root.1.2.3');

insert into public.position (id, name, access_level) values
  (1, 'Rifleman', 'member'),
  (2, 'Squad Leader', 'leader'),
  (3, 'Platoon Leader', 'leader');

insert into public.assignment (user_id, unit_id, position_id) values
  (1, 4, 1), -- private axe, ap1s1, rifleman
  (2, 4, 2), -- sergeant bug, ap1s1, squad leader
  (3, 3, 3); -- lieutenant cup, ap1, platoon leader

insert into public.permission (unit_id, access_level, ability) values
  (3, 'leader', 'add_event'); -- ap1

-- select diag(permissions_on_unit(3, 4));
select is(
  'add_event' = any(permissions_on_unit(3, 4)),
  true,
  'lieutenant cup can add_event on ap1s1'
);

select diag(permissions_on_unit(1, 4));

select is(
  'add_event' = any(permissions_on_unit(1, 4)),
  false,
  'private axe cannot add_event on ap1s1'
);

select * from finish();
rollback;
