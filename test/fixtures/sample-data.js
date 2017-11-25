const ids = {
  privateAxe: 1,
  sergeantBug: 2,
  lieutenantCup: 3,
  technicianDew: 4,
  bnhq: 1,
  able: 2,
  ap1: 3,
  ap1s1: 4,
  rifleman: 1,
  squadLeader: 2,
  platoonLeader: 3,
  platoonClerk: 4
}

const insertSampleData = `
  insert into personnel.user (id, first_name, last_name) values
    (${ids.privateAxe}, 'Private', 'Axe'),
    (${ids.sergeantBug}, 'Sergeant', 'Bug'),
    (${ids.lieutenantCup}, 'Lieutenant', 'Cup'),
    (${ids.technicianDew}, 'Technician', 'Dew');

  insert into personnel.unit (id, abbr, parent_path) values
    (${ids.bnhq}, 'Bn HQ', 'root'),
    (${ids.able}, 'Able', 'root.${ids.bnhq}'), -- root.1
    (${ids.ap1}, 'AP1', 'root.${ids.bnhq}.${ids.able}'), -- root.1.2
    (${ids.ap1s1}, 'AP1S1', 'root.${ids.bnhq}.${ids.able}.${ids.ap1}'); -- root.1.2.3

  insert into personnel.position (id, name, access_level) values
    (${ids.rifleman}, 'Rifleman', 'member'),
    (${ids.squadLeader}, 'Squad Leader', 'leader'),
    (${ids.platoonLeader}, 'Platoon Leader', 'leader'),
    (${ids.platoonClerk}, 'Platoon Clerk', 'clerk');

  insert into personnel.assignment (user_id, unit_id, position_id) values
    (${ids.privateAxe}, ${ids.ap1s1}, ${ids.rifleman}),
    (${ids.sergeantBug}, ${ids.ap1s1}, ${ids.squadLeader}),
    (${ids.lieutenantCup}, ${ids.ap1}, ${ids.platoonLeader}),
    (${ids.technicianDew}, ${ids.ap1s1}, ${ids.rifleman}),
    (${ids.technicianDew}, ${ids.ap1}, ${ids.platoonClerk});

  insert into personnel.permission (unit_id, access_level, ability) values
    (${ids.ap1}, 'leader', 'add_promotion'),
    (${ids.ap1}, 'clerk', 'add_event'),
    (${ids.ap1s1}, 'member', 'view_event'),
    (${ids.ap1}, 'member', 'view_event'),
    (${ids.ap1}, 'clerk', 'edit_profile');

  insert into personnel.event (unit_id, name) values
    (${ids.able}, 'Able Company Drills'),
    (${ids.ap1}, 'AP1 Platoon Drills'),
    (${ids.ap1s1}, 'AP1S1 Squad Drills');
`

module.exports = {
  insertSampleData,
  ids
}
