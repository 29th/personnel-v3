import { Model } from 'objection'
// import Unit from './unit'
// import User from './user'
// import Position from './position'

export default class Assignment extends Model {
  static tableName = 'assignments'

  static relationMappings = {
    unit: {
      relation: Model.BelongsToOneRelation,
      // modelClass: Unit,
      modelClass: __dirname + '/Unit',
      join: {
        from: 'assignments.unitId',
        to: 'units.id'
      }
    },
    user: {
      relation: Model.BelongsToOneRelation,
      // modelClass: User,
      modelClass: __dirname + '/User',
      join: {
        from: 'assignments.userId',
        to: 'users.id'
      }
    },
    position: {
      relation: Model.BelongsToOneRelation,
      // modelClass: Position,
      modelClass: __dirname + '/Position',
      join: {
        from: 'assignments.positionId',
        to: 'positions.id'
      }
    }
  }
}
