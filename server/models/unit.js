import { Model } from 'objection'
import Assignment from './assignment'
import Permission from './permission'

export default class Unit extends Model {
  static tableName = 'units'

  static relationMappings = {
    assignments: {
      relation: Model.HasManyRelation,
      modelClass: Assignment,
      join: {
        from: 'units.id',
        to: 'assignments.unitId'
      }
    },
    permissions: {
      relation: Model.HasManyRelation,
      modelClass: Permission,
      join: {
        from: 'units.id',
        to: 'permissions.unitId'
      }
    }
  }
}
