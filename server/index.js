import { ApolloServer, ForbiddenError } from 'apollo-server'
import { Model } from 'objection'
import { readFileSync } from 'fs'
import { join } from 'path'
import flatten from 'lodash/flatten'
import Knex from 'knex'
import knexfile from '../knexfile'

import User from './models/User'
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
    }
  }
}

async function getPermissions (actorId) {
  const user = await User.query()
    .findById(actorId)
    .eager('assignments.unit.permissions')

  const assignmentPermissions = user.assignments.map((assignment) => assignment.unit.permissions)
  const permissions = flatten(assignmentPermissions)
  const abilities = permissions.map((permission) => permission.ability)
  return abilities
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
