import { Model } from 'objection'

export default class Permission extends Model {
  static tableName = 'permissions'

  static relationMappings = {
    unit: {
      relation: Model.BelongsToOneRelation,
      modelClass: __dirname + '/unit',
      join: {
        from: 'permissions.unitId',
        to: 'units.id'
      }
    }
  }
}
