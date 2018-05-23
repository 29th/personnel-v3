import { Model } from 'objection'
import User from '../../server/models/user'

export async function seed (db) {
  Model.knex(db)

  User.query().insertGraph({
    lastName: 'Wilson',
    assignments: [
      {
        unit: {
          abbr: 'AP1',
          permissions: [
            { ability: 'edit_user', accessLevel: 'clerk' }
          ]
        },
        position: {
          name: 'Platoon Leader',
          accessLevel: 'leader'
        }
      }
    ]
  })
}
