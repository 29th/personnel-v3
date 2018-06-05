import { raw } from 'objection'
import flatten from 'lodash/flatten'
import User from './models/user'
import Unit from './models/unit'
import Assignment from './models/assignment'

export async function getPermissions (actorId) {
  const assignments = await Assignment.query()
    .select('permissions.*')
    .where('userId', actorId)
    .joinRelation('position')
    .join(raw(`
      permissions on (
        permissions.unit_id = assignments.unit_id
        and permissions.access_level <= position.access_level
      )
    `))
    // .joinEager('[position, unit.permissions]')
    // .modifyEager('unit.permissions', (query) => {
    //   query.where('permissions', '<=', raw('??', 'position.accessLevel'))
    // })
  const abilities = assignments.map((permission) => permission.ability)
  return abilities
}

export async function getPermissionsOnUnit (actorId, unitId) {
  // const user = await User.query()
  //   .findById(actorId)
  //   .$relatedQuery('assignments')
  //   .eager('unit.permissions')
  //   .where('unit.id', unitId)
  //   .orWhere('unit.parentPath', '@>', Unit.query().findById(unitId))
  // console.log(user)
  // return User.raw(`
  //   select permissions.*
  //   from assignments
  //   inner join units on (units.id = assignments.unit_id)
  //   inner join positions on (positions.id = assignments.position_id)
  //   inner join permissions on (
  //     permissions.unit_id = assignments.unit_id
  //     and permissions.access_level <= positions.access_level
  //   )
  //   where assignments.user_id = :actorId:
  //   and (
  //     units.id = :unitId:
  //     or  units.parent_path @> (
  //       select parent_path from units where id = :unitId:
  //     )
  //   )
  // `, { actorId, unitId })

  const assignments = await Assignment.query()
    .select('permissions.*')
    .where('userId', actorId)
    .joinRelation('position')
    .join(raw(`
      permissions on (
        permissions.unit_id = assignments.unit_id
        and permissions.access_level <= position.access_level
      )
    `))
    .joinRelation('unit')
    .andWhere((query) => {
      query.where('unit.id', unitId)
        .orWhere(raw(`
          unit.parent_path @> (
            select parent_path from unit where id = :unitId
          )
        `, { unitId }))
    })
    .debug()
  console.log(assignments)
  return assignments.map((permission) => permission.ability)
}

export async function getPermissionsOnUser (actorId, subjectId) {
  return []
}
