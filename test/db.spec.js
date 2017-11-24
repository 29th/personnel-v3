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
  })

  afterEach(async () => {
    await client.query('rollback')
  })

  test('Proof of concept', async () => {
    await client.query(createOrgChart)
    const result = await client.query(`select permissions_on_unit(${ids.lieutenantCup}, ${ids.technicianDew})`)
    const permissions = result.rows[0].permissions_on_unit
    expect(permissions).toEqual(['add_promotion', 'add_event'])
  })
})
