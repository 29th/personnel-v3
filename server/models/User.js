import { Model } from 'objection'
import Assignment from './assignment'
import Rank from './rank'

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
      modelClass: Assignment,
      join: {
        from: 'users.id',
        to: 'assignments.userId'
      }
    },
    rank: {
      relation: Model.BelongsToOneRelation,
      modelClass: Rank,
      join: {
        from: 'users.rankId',
        to: 'ranks.id'
      }
    }
  }
}
