import { ApolloServer, ForbiddenError } from 'apollo-server'
import { Model } from 'objection'
import { readFileSync } from 'fs'
import { join } from 'path'
import Knex from 'knex'
import knexfile from '../knexfile'

import User from './models/user'
import { getPermissions } from './permissions'
const SCHEMA_FILE = join(__dirname, 'schema.graphql')
const typeDefs = readFileSync(SCHEMA_FILE, 'utf8')

const db = Knex(knexfile)
Model.knex(db)

const resolvers = {
  Query: {
    users: () => User.query()
  },
  Mutation: {
    createUser: async (parent, { data }, { actorId }) => {
      const permissions = await getPermissions(actorId)
      if (!permissions.includes('add_user')) {
        throw ForbiddenError('Not authorized to add_user')
      }
      return User
        .query()
        .insert(data)
        .returning('*')
    },
    updateUser: async (parent, { data, where }, { actorId }) => {
      const subjectId = where.id
      const permissions = await getPermissionsOnUser(actorId, subjectId)
      if (!permissions.includes('edit_user')) {
        throw ForbiddenError('Not authorised to edit_user')
      }
      return User
        .query()
        .patch(data)
        .where(where)
        .returning('*')
    }
  }
}

const server = new ApolloServer({
  typeDefs,
  resolvers,
  debug: true,
  context: ({ req }) => ({
    actorId: req.headers['x-unsafe-user']
  })
})

server.listen().then(({ url }) => {
  console.log(`🚀 Server ready at ${url}`)
})
