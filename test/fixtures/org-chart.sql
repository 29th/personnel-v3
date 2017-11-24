insert into public.user (id, first_name, last_name) values
  ({{ privateAxe }}, 'Private', 'Axe'),
  ({{ sergeantBug }}, 'Sergeant', 'Bug'),
  ({{ lieutenantCup }}, 'Lieutenant', 'Cup'),
  ({{ technicianDew }}, 'Technician', 'Dew');

insert into public.unit (id, abbr, parent_path) values
  ({{ bnhq }}, 'Bn HQ', 'root'),
  ({{ able }}, 'Able', 'root.{{ bnhq }}'), -- root.1
  ({{ ap1 }}, 'AP1', 'root.{{ bnhq }}.{{ able }}'), -- root.1.2
  ({{ ap1s1 }}, 'AP1S1', 'root.{{ bnhq }}.{{ able }}.{{ ap1 }}'); -- root.1.2.3

insert into public.position (id, name, access_level) values
  ({{ rifleman }}, 'Rifleman', 'member'),
  ({{ squadLeader }}, 'Squad Leader', 'leader'),
  ({{ platoonLeader }}, 'Platoon Leader', 'leader'),
  ({{ platoonClerk }}, 'Platoon Clerk', 'clerk');

insert into public.assignment (user_id, unit_id, position_id) values
  (1, 4, 1), -- private axe, ap1s1, rifleman
  (2, 4, 2), -- sergeant bug, ap1s1, squad leader
  (3, 3, 3), -- lieutenant cup, ap1, platoon leader
  (4, 4, 1), -- technician dew, ap1s1, rifleman
  (4, 3, 4); -- technician dew, ap1, platoon clerk

insert into public.permission (unit_id, access_level, ability) values
  ({{ ap1 }}, 'leader', 'add_promotion'),
  ({{ ap1 }}, 'clerk', 'add_event'),
  ({{ ap1s1 }}, 'member', 'view_event');
