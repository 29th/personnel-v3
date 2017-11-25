const assert = require('assert')
const { Client } = require('pg')
const { insertSampleData, ids } = require('./fixtures/sample-data')

const DATABASE_URL = process.env.DATABASE_URL
assert(DATABASE_URL, 'Expected DATABASE_URL environment variable to be set')
const client = new Client({ connectionString: DATABASE_URL })

describe('Database permission functions', () => {
  beforeAll(async () => {
    await client.connect()
  })

  afterAll(async () => {
    await client.end()
  })

  beforeEach(async () => {
    await client.query('begin')
    await client.query(insertSampleData)
  })

  afterEach(async () => {
    await client.query('rollback')
  })

  describe('permissions_on_unit', () => {
    test('lieutenant cup can add_promotion and add_event on ap1s1', async () => {
      const permissions = await permissionsOnUnit(ids.lieutenantCup, ids.ap1s1)
      expect(permissions).toContain('add_promotion')
      expect(permissions).toContain('add_event')
      expect(permissions).toContain('edit_profile')
    })

    test('technician dew can add_event and edit_profile on ap1', async () => {
      const permissions = await permissionsOnUnit(ids.technicianDew, ids.ap1)
      expect(permissions).toContain('add_event')
      expect(permissions).toContain('edit_profile')
      expect(permissions).not.toContain('add_promotion')
    })

    test('technician dew can add_event and view_event on ap1s1', async () => {
      const permissions = await permissionsOnUnit(ids.technicianDew, ids.ap1s1)
      expect(permissions).toContain('add_event')
      expect(permissions).toContain('edit_profile')
      expect(permissions).not.toContain('add_promotion')
    })

    test('private axe can view_event on ap1s1', async () => {
      const permissions = await permissionsOnUnit(ids.privateAxe, ids.ap1s1)
      expect(permissions).toEqual(['view_event'])
      expect(permissions).not.toContain('add_event')
      expect(permissions).not.toContain('edit_profile')
      expect(permissions).not.toContain('add_promotion')
    })

    test('private axe can do nothing on ap1', async () => {
      const permissions = await permissionsOnUnit(ids.privateAxe, ids.ap1)
      expect(permissions.length).toBe(0)
    })
  })

  describe('permissions_on_user', () => {
    test('lieutenant cup can add_promotion and edit_profile on private axe', async () => {
      const permissions = await permissionsOnUser(ids.lieutenantCup, ids.privateAxe)
      expect(permissions).toContain('add_promotion')
      expect(permissions).toContain('edit_profile')
    })
  })

  describe('row level security', () => {
    test('personnel_anonymous cannot select events', async () => {
      await client.query(`set role personnel_anonymous`)
      const sql = `select * from personnel.event`
      expect(client.query(sql)).rejects.toBeDefined()
    })

    test('personnel_user with no claim gets empty set of events', async () => {
      await client.query(`set role personnel_user`)
      const sql = `select * from personnel.event`
      const result = await client.query(sql)
      expect(result.rows.length).toBe(0)
    })

    test('technician dew can see ap1 and ap1s1 events', async () => {
      await client.query(`set role personnel_user`)
      await client.query(`set local jwt.claims.user_id to '${ids.technicianDew}'`)
      const sql = `select * from personnel.event`
      const result = await client.query(sql)
      expect(result.rows.length).toBe(2)
    })
  })
})

async function permissionsOnUnit (actorId, unitId) {
  const sql = `select personnel.permissions_on_unit(${actorId}, ${unitId})`
  const result = await client.query(sql)
  return result.rows[0].permissions_on_unit
}

async function permissionsOnUser (actorId, subjectId) {
  const sql = `select personnel.permissions_on_user(${actorId}, ${subjectId})`
  const result = await client.query(sql)
  return result.rows[0].permissions_on_user
}
