const knex = require('knex')({ client: 'pg' })

module.exports = {
  createUsers,
  createUnits,
  createPositions,
  createAssignments,
  createPermissions
}

function createUsers (ids) {
  return knex.insert([
    {
      id: ids.privateAxe,
      first_name: 'Private',
      last_name: 'Axe'
    },
    {
      id: ids.sergeantBug,
      first_name: 'Sergeant',
      last_name: 'Bug'
    },
    {
      id: ids.lieutenantCup,
      first_name: 'Lieutenant',
      last_name: 'Cup'
    },
    {
      id: ids.technicianDew,
      first_name: 'Technician',
      last_name: 'Dew'
    }
  ])
  .into('public.user')
  .toString()
}

function createUnits (ids) {
  return knex.insert([
    {
      id: ids.bnhq,
      abbr: 'Bn HQ',
      parent_path: `root`
    },
    {
      id: ids.able,
      abbr: 'Able',
      parent_path: `root.${ids.bnhq}` // root.1
    },
    {
      id: ids.ap1,
      abbr: 'AP1',
      parent_path: `root.${ids.bnhq}.${ids.able}` // root.1.2
    },
    {
      id: ids.ap1s1,
      abbr: 'AP1S1',
      parent_path: `root.${ids.bnhq}.${ids.able}.${ids.ap1}` // root.1.2.3
    }
  ])
  .into('public.unit')
  .toString()
}

function createPositions (ids) {
  return knex.insert([
    {
      id: ids.rifleman,
      name: 'Rifleman',
      access_level: 'member'
    },
    {
      id: ids.squadLeader,
      name: 'Squad Leader',
      access_level: 'leader'
    },
    {
      id: ids.platoonLeader,
      name: 'Platoon Leader',
      access_level: 'leader'
    },
    {
      id: ids.platoonClerk,
      name: 'Platoon Clerk',
      access_level: 'clerk'
    }
  ])
  .into('public.position')
  .toString()
}

function createAssignments (ids) {
  return knex.insert([
    {
      user_id: ids.privateAxe,
      unit_id: ids.ap1s1,
      position_id: ids.rifleman
    },
    {
      user_id: ids.sergeantBug,
      unit_id: ids.ap1s1,
      position_id: ids.squadLeader
    },
    {
      user_id: ids.lieutenantCup,
      unit_id: ids.ap1,
      position_id: ids.platoonLeader
    },
    {
      user_id: ids.technicianDew,
      unit_id: ids.ap1s1,
      position_id: ids.rifleman
    },
    {
      user_id: ids.technicianDew,
      unit_id: ids.ap1,
      position_id: ids.platoonClerk
    }
  ])
  .into('public.assignment')
  .toString()
}

function createPermissions (ids) {
  return knex.insert([
    {
      unit_id: ids.ap1,
      access_level: 'leader',
      ability: 'add_promotion'
    },
    {
      unit_id: ids.ap1,
      access_level: 'clerk',
      ability: 'add_event'
    },
    {
      unit_id: ids.ap1s1,
      access_level: 'member',
      ability: 'view_event'
    }
  ])
  .into('public.permission')
  .toString()
}
