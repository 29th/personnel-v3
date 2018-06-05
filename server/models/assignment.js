import { Model } from 'objection'

export default class Assignment extends Model {
  static tableName = 'assignments'

  static relationMappings = {
    unit: {
      relation: Model.BelongsToOneRelation,
      modelClass: __dirname + '/unit',
      join: {
        from: 'assignments.unitId',
        to: 'units.id'
      }
    },
    user: {
      relation: Model.BelongsToOneRelation,
      modelClass: __dirname + '/user',
      join: {
        from: 'assignments.userId',
        to: 'users.id'
      }
    },
    position: {
      relation: Model.BelongsToOneRelation,
      modelClass: __dirname + '/position',
      join: {
        from: 'assignments.positionId',
        to: 'positions.id'
      }
    }
  }
}
