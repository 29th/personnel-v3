do $$
declare
  pvt_axe integer := 1;
begin

insert into public.user (id, first_name, last_name) values
  (pvt_axe, 'Private', 'Axe'),
  (2, 'Sergeant', 'Bug'),
  (3, 'Lieutenant', 'Cup'),
  (4, 'Technician', 'Dew');

insert into public.unit (id, abbr, parent_path) values
  (1, 'Bn HQ', 'root'),
  (2, 'Able', 'root.1'),
  (3, 'AP1', 'root.1.2'),
  (4, 'AP1S1', 'root.1.2.3');

insert into public.position (id, name, access_level) values
  (1, 'Rifleman', 'member'),
  (2, 'Squad Leader', 'leader'),
  (3, 'Platoon Leader', 'leader'),
  (4, 'Platoon Clerk', 'clerk');

insert into public.assignment (user_id, unit_id, position_id) values
  (1, 4, 1), -- private axe, ap1s1, rifleman
  (2, 4, 2), -- sergeant bug, ap1s1, squad leader
  (3, 3, 3), -- lieutenant cup, ap1, platoon leader
  (4, 4, 1), -- technician dew, ap1s1, rifleman
  (4, 3, 4); -- technician dew, ap1, platoon clerk

insert into public.permission (unit_id, access_level, ability) values
  (3, 'leader', 'add_promotion'), -- ap1
  (3, 'clerk', 'add_event'), -- ap1
  (4, 'member', 'view_event'); -- ap1s1

end $$;
