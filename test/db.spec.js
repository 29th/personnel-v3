import assert from 'assert'
import knex from 'knex'
import caseConverter from 'knex-case-converter-plugin'
import insertSampleData from './fixtures/sample-data'

const DATABASE_URL = process.env.DATABASE_URL
assert(DATABASE_URL, 'Expected DATABASE_URL environment variable to be set')

const db = knex({
  client: 'pg',
  connection: DATABASE_URL,
  ...caseConverter
})

describe('Database permission functions', () => {
  let transaction
  let sampleData

  beforeEach(async () => {
    // TODO: Is there a way around promisifying this?
    transaction = await new Promise((resolve, reject) => {
      db.transaction((trx) => {
        resolve(trx)
      }).catch((err) => {
        reject(err)
      })
    })
    sampleData = await insertSampleData(transaction)
  })

  afterEach(async () => {
    transaction.rollback()
  })

  afterAll(async () => {
    db.destroy()
  })

  describe('permissions_on_unit', () => {
    test('Platoon leader can add_promotion and add_event on one of their squads', async () => {
      const { users, units } = sampleData
      const foo = { ...users }
      const permissions = await permissionsOnUnit(users.ltChicken, units.ap1s1)
      expect(permissions).toContain('add_promotion')
      expect(permissions).toContain('add_event')
      expect(permissions).toContain('edit_profile')
    })

    test('Platoon clerk can add_event and edit_profile on their platoon', async () => {
      const { users, units } = sampleData
      const permissions = await permissionsOnUnit(users.t5Dingo, units.ap1)
      expect(permissions).toContain('add_event')
      expect(permissions).toContain('edit_profile')
      expect(permissions).not.toContain('add_promotion')
    })

    test('Platoon clerk can add_event and view_event on ap1s1', async () => {
      const { users, units } = sampleData
      const permissions = await permissionsOnUnit(users.t5Dingo, units.ap1s1)
      expect(permissions).toContain('add_event')
      expect(permissions).toContain('edit_profile')
      expect(permissions).not.toContain('add_promotion')
    })

    test('Rifleman can view_event on their squad', async () => {
      const { users, units } = sampleData
      const permissions = await permissionsOnUnit(users.pvtAntelope, units.ap1s1)
      expect(permissions).toEqual(['view_event'])
      expect(permissions).not.toContain('add_event')
      expect(permissions).not.toContain('edit_profile')
      expect(permissions).not.toContain('add_promotion')
    })

    test('Rifleman can do nothing on their platoon', async () => {
      const { users, units } = sampleData
      const permissions = await permissionsOnUnit(users.pvtAntelope, units.ap1)
      expect(permissions).toHaveLength(0)
    })
  })

  describe('permissions_on_user', () => {
    test('Platoon leader can add_promotion and edit_profile on a Rifleman in their platoon', async () => {
      const { users } = sampleData
      const permissions = await permissionsOnUser(users.ltChicken, users.pvtAntelope)
      expect(permissions).toContain('add_promotion')
      expect(permissions).toContain('edit_profile')
    })
  })

  describe('row level security', () => {
    test('personnel_anonymous cannot select events', async () => {
      await transaction.raw('set role personnel_anonymous')
      const query = transaction('personnel.event').select('*')
      await expect(query).rejects.toBeDefined()
    })

    test('personnel_user with no claim gets empty set of events', async () => {
      await transaction.raw(`set role personnel_user`)
      const result = await transaction('personnel.event').select('*')
      expect(result).toHaveLength(0)
    })

    test('Platoon clerk can see events from their squad and platoon', async () => {
      const { users, units } = sampleData
      await transaction.raw(`set role personnel_user`)
      await transaction.raw(`set local jwt.claims.user_id to '${users.t5Dingo}'`)
      const result = await transaction('personnel.event').select('*')
      expect(result).toHaveLength(2)
    })

    test('Platoon clerk can add events to their platoon', async () => {
      const { users, units } = sampleData
      await transaction.raw(`set role personnel_user`)
      await transaction.raw(`set local jwt.claims.user_id to '${users.t5Dingo}'`)
      const query = transaction('personnel.event')
        .insert({ unitId: units.ap1, name: 'AP1 test' })
      await expect(query).resolves.toBeDefined()
    })

    test('Platoon clerk can not add events to their company', async () => {
      const { users, units } = sampleData
      await transaction.raw(`set role personnel_user`)
      await transaction.raw(`set local jwt.claims.user_id to '${users.t5Dingo}'`)
      const query = transaction('personnel.event')
        .insert({ unitId: units.able, name: 'Able test' })
      await expect(query).rejects.toBeDefined()
    })
  })

  async function permissionsOnUnit (actorId, unitId) {
    const result = await transaction
      .raw('select personnel.permissions_on_unit(?, ?)', [actorId, unitId])
    return result.rows[0].permissions_on_unit
  }

  async function permissionsOnUser (actorId, subjectId) {
    const result = await transaction
      .raw('select personnel.permissions_on_user(?, ?)', [actorId, subjectId])
    return result.rows[0].permissions_on_user
  }
})
