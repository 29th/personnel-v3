import { Model } from 'objection'
import Unit from './unit'

export default class Permission extends Model {
  static tableName = 'permissions'

  static relationMappings = {
    unit: {
      relation: Model.BelongsToOneRelation,
      modelClass: Unit,
      join: {
        from: 'permissions.unitId',
        to: 'units.id'
      }
    }
  }
}
