const assert = require('assert')
const { Client } = require('pg')
const fs = require('fs')
const { join } = require('path')

const orgChart = fs.readFileSync(join(__dirname, 'fixtures/org-chart.sql'), 'utf8')
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
    await client.query(orgChart)
    const res = await client.query('select permissions_on_unit(3, 4)')
    console.log(res.rows[0])
  })
})
