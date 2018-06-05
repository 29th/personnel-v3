import Knex from 'knex'
import { seed } from '../database/seeds/sample'
import knexfile from '../knexfile'
import User from './models/user'
import Unit from './models/unit'
import { getPermissions, getPermissionsOnUnit } from './permissions'

const db = Knex(knexfile)

describe('Permissions', () => {
  let transaction

  beforeEach(async () => {
    transaction = await new Promise((resolve, reject) => {
      db.transaction((trx) => {
        resolve(trx)
      }).catch((err) => {
        reject(err)
      })
    })
    await seed(transaction)
  })

  afterEach(async() => {
    await transaction.rollback()
  })

  afterAll(async () => {
    await db.destroy()
  })

  describe('getPermissions', () => {
    test('Platoon leader inherits member and clerk abilities', async () => {
      const user = await getUserByPositionName('Platoon Leader')
      const permissions = await getPermissions(user.id)
      expect(permissions).toContain('add_promotion') // leader-level
      expect(permissions).toContain('add_event') // clerk-level
      expect(permissions).toContain('view_event') // member-level
    })

    test('Platoon clerk inherits member abilities but not leader abilities', async () => {
      const user = await getUserByPositionName('Platoon Clerk')
      const permissions = await getPermissions(user.id)
      expect(permissions).not.toContain('add_promotion') // leader-level
      expect(permissions).toContain('add_event') // clerk-level
      expect(permissions).toContain('view_event') // member-level
    })
  })

  describe('getPermissionsOnUnit', () => {
    test('Platoon leader platoon-level abilities apply to their squad', async () => {
      const user = await getUserByPositionName('Platoon Leader')
      const unit = await getUnitByAbbr('AP1S1')
      const permissions = await getPermissionsOnUnit(user.id, unit.id)
      expect(permissions).toContain('add_event') // clerk-level
    })
  })
})

function getUserByPositionName (positionName) {
  return User
    .query()
    .joinRelation('assignments.position')
    .where('assignments:position.name', positionName)
    .first()
}

function getUnitByAbbr (abbr) {
  return Unit
    .query()
    .where('abbr', abbr)
    .first()
}
