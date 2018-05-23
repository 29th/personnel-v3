import { knexSnakeCaseMappers } from 'objection'

module.exports = {
  client: 'pg',
  connection: process.env.DATABASE_URL,
  migrations: {
    directory: './database/migrations'
  },
  seeds: {
    directory: './database/seeds'
  },
  ...knexSnakeCaseMappers()
}
