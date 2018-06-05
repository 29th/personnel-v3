import assert from 'assert'
import { knexSnakeCaseMappers } from 'objection'

const DATABASE_URL = process.env.DATABASE_URL
assert(DATABASE_URL, 'Expected DATABASE_URL environment variable to be set')

module.exports = {
  client: 'pg',
  connection: DATABASE_URL,
  migrations: {
    directory: './database/migrations'
  },
  seeds: {
    directory: './database/seeds'
  },
  ...knexSnakeCaseMappers()
}
