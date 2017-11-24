const assert = require('assert')
const { Client } = require('pg')
const { createOrgChart, ids } = require('./fixtures/org-chart')

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
    await client.query(createOrgChart)
  })

  afterEach(async () => {
    await client.query('rollback')
  })

  describe('permissions_on_unit', () => {
    test('lieutenant cup can add_promotion and add_event on ap1s1', async () => {
      const permissions = await permissionsOnUnit(ids.lieutenantCup, ids.ap1s1)
      expect(permissions).toEqual(['add_promotion', 'add_event'])
    })

    test('technician dew can add_event on ap1', async () => {
      const permissions = await permissionsOnUnit(ids.technicianDew, ids.ap1)
      expect(permissions).toEqual(['add_event'])
    })

    test('technician dew can add_event and view_event on ap1s1', async () => {
      const permissions = await permissionsOnUnit(ids.technicianDew, ids.ap1s1)
      expect(permissions).toEqual(['add_event', 'view_event'])
    })

    test('private axe can view_event on ap1s1', async () => {
      const permissions = await permissionsOnUnit(ids.privateAxe, ids.ap1s1)
      expect(permissions).toEqual(['view_event'])
    })

    test('private axe can do nothing on ap1', async () => {
      const permissions = await permissionsOnUnit(ids.privateAxe, ids.ap1)
      expect(permissions.length).toBe(0)
    })
  })
})

async function permissionsOnUnit (actorId, unitId) {
  const sql = `select permissions_on_unit(${actorId}, ${unitId})`
  const result = await client.query(sql)
  return result.rows[0].permissions_on_unit
}
