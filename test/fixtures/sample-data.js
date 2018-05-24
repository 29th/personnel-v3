export default async function insertSampleData (transaction) {
  // Units
  const bnhq = await insertOne('unit', {
    abbr: 'Bn Hq',
    parentPath: `root`
  })
  const able = await insertOne('unit', {
    abbr: 'Able',
    parentPath: `root.${bnhq}`
  })
  const ap1 = await insertOne('unit', {
    abbr: 'AP1',
    parentPath: `root.${bnhq}.${able}`
  })
  const ap1s1 = await insertOne('unit', {
    abbr: 'AP1S1',
    parentPath: `root.${bnhq}.${able}.${ap1}`
  })
  const units = { bnhq, able, ap1, ap1s1 }

  // Ranks
  const [
    pvt,
    sgt,
    lt,
    t5
  ] = await insertMany('rank', [
    { abbr: 'Pvt.' },
    { abbr: 'Sgt.' },
    { abbr: 'Lt.' },
    { abbr: 'T/5' }
  ])
  const ranks = { pvt, sgt, lt, t5 }

  // Positions
  const [
    rifleman,
    squadLeader,
    platoonLeader,
    platoonClerk
  ] = await insertMany('position', [
    { name: 'Rifleman', accessLevel: 'member' },
    { name: 'Squad Leader', accessLevel: 'leader' },
    { name: 'Platoon Leader', accessLevel: 'leader' },
    { name: 'Platoon Clerk', accessLevel: 'clerk' }
  ])
  const positions = { rifleman, squadLeader, platoonLeader, platoonClerk }

  // Users
  const [
    pvtAntelope,
    sgtBaboon,
    ltChicken,
    t5Dingo
  ] = await insertMany('user', [
    { lastName: 'Antelope', rankId: ranks.pvt },
    { lastName: 'Baboon', rankId: ranks.sgt },
    { lastName: 'Chicken', rankId: ranks.lt },
    { lastName: 'Dingo', rankId: ranks.t5 }
  ])
  const users = { pvtAntelope, sgtBaboon, ltChicken, t5Dingo }

  // Assignments
  await insertMany('assignment', [
    {
      userId: users.pvtAntelope,
      unitId: units.ap1s1,
      positionId: positions.rifleman
    },
    {
      userId: users.sgtBaboon,
      unitId: units.ap1s1,
      positionId: positions.squadLeader
    },
    {
      userId: users.ltChicken,
      unitId: units.ap1,
      positionId: positions.platoonLeader
    },
    {
      userId: users.t5Dingo,
      unitId: units.ap1s1,
      positionId: positions.rifleman
    },
    {
      userId: users.t5Dingo,
      unitId: units.ap1,
      positionId: positions.platoonClerk
    }
  ])

  // Permissions
  await insertMany('permission', [
    {
      unitId: units.ap1,
      accessLevel: 'leader',
      ability: 'add_promotion'
    },
    {
      unitId: units.ap1,
      accessLevel: 'clerk',
      ability: 'add_event'
    },
    {
      unitId: units.ap1s1,
      accessLevel: 'member',
      ability: 'view_event'
    },
    {
      unitId: units.ap1,
      accessLevel: 'member',
      ability: 'view_event'
    },
    {
      unitId: units.ap1,
      accessLevel: 'clerk',
      ability: 'edit_profile'
    }
  ])
 
  // Events
  await insertMany('event', [
    { unitId: units.able, name: 'Able Company Drills' },
    { unitId: units.ap1, name: 'AP1 Platoon Drills' },
    { unitId: units.ap1s1, name: 'AP1S1 Squad Drills' }
  ])

  return {
    units,
    ranks,
    positions,
    users
  }

  // Helper functions
  function insertOne (table, row) {
    return insertMany(table, row)
      .then((results) => results[0])
  }

  function insertMany (table, rows) {
    return transaction
      .withSchema('personnel')
      .insert(rows)
      .into(table)
      .returning('*') // returning('id') doesn't seem to work so we map it below
      .then((rows) => rows.map((row) => row.id))
  }
}
