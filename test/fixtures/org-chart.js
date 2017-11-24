export const ids = {
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

export const insertUsers = `
  insert into public.user (id, first_name, last_name) values
    (${ids.privateAxe}, 'Private', 'Axe'),
    (${ids.sergeantBug}, 'Sergeant', 'Bug'),
    (${ids.lieutenantCup}, 'Lieutenant', 'Cup'),
    (${ids.technicianDew}, 'Technician', 'Dew')
`

// parent_path are: root, root.1, root.1.2, root.1.2.3
export const insertUnits = `
  insert into public.unit (id, abbr, parent_path) values
    (${ids.bnhq}, 'Bn HQ', 'root'),
    (${ids.able}, 'Able', 'root.${ids.bnhq}'),
    (${ids.ap1}, 'AP1', 'root.${ids.bnhq}.${ids.able}'),
    (${ids.ap1s1}, 'AP1S1', 'root.${ids.bnhq}.${ids.able}.${ids.ap1}')
`

export const insertPositions = `
  insert into public.position (id, name, access_level) values
    (${ids.rifleman}, 'Rifleman', 'member'),
    (${ids.squadLeader}, 'Squad Leader', 'leader'),
    (${ids.platoonLeader}, 'Platoon Leader', 'leader'),
    (${ids.platoonClerk}, 'Platoon Clerk', 'clerk')
`

export const insertAssignments = `
  insert into public.assignment (user_id, unit_id, position_id) values
    (${ids.privateAxe}, ${ids.ap1s1}, ${ids.rifleman}),
    (${ids.sergeantBug}, ${ids.ap1s1}, ${ids.squadLeader}),
    (${ids.lieutenantCup}, ${ids.ap1}, ${ids.platoonLeader}),
    (${ids.technicianDew}, ${ids.ap1s1}, ${ids.rifleman}),
    (${ids.technicianDew}, ${ids.ap1}, ${ids.platoonClerk})
`

export const insertPermissions = `
  insert into public.permission (unit_id, access_level, ability) values
    (${ids.ap1}, 'leader', 'add_promotion'),
    (${ids.ap1}, 'clerk', 'add_event'),
    (${ids.ap1s1}, 'member', 'view_event')
`
