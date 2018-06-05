import { Model } from 'objection'

export default class Unit extends Model {
  static tableName = 'units'

  static relationMappings = {
    assignments: {
      relation: Model.HasManyRelation,
      modelClass: __dirname + '/assignment',
      join: {
        from: 'units.id',
        to: 'assignments.unitId'
      }
    },
    permissions: {
      relation: Model.HasManyRelation,
      modelClass: __dirname + '/permission',
      join: {
        from: 'units.id',
        to: 'permissions.unitId'
      }
    }
  }
}
