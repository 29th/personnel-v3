import { Model } from 'objection'

export default class User extends Model {
  static tableName = 'users'

  static jsonSchema = {
    type: 'object',
    required: ['lastName'],
    properties: {
      id: { type: 'integer' },
      firstName: { type: 'string', minLength: 1, maxLength: 255 },
      lastName: { type: 'string', minLength: 1, maxLength: 255 }
    }
  }

  static relationMappings = {
    assignments: {
      relation: Model.HasManyRelation,
      modelClass: __dirname + '/assignment',
      join: {
        from: 'users.id',
        to: 'assignments.userId'
      }
    },
    rank: {
      relation: Model.BelongsToOneRelation,
      modelClass: __dirname + '/rank',
      join: {
        from: 'users.rankId',
        to: 'ranks.id'
      }
    }
  }
}
