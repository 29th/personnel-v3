import { Model } from 'objection'
import User from '../../server/models/user'
import Unit from '../../server/models/unit'
import Rank from '../../server/models/rank'
import Position from '../../server/models/position'
import Permission from '../../server/models/permission'
import Assignment from '../../server/models/assignment'

export async function seed (db) {
  Model.knex(db)

  await Promise.all([
    Unit.query().delete(),
    User.query().delete(),
    Rank.query().delete(),
    Position.query().delete(),
    Permission.query().delete(),
    Assignment.query().delete()
  ])

  await Unit.query().insertGraph([
    {
      '#id': 'bnhq',
      abbr: 'Bn HQ',
      parentPath: 'root'
    },
    {
      '#id': 'able',
      abbr: 'Able',
      parentPath: '#ref{bnhq.parentPath}.#ref{bnhq.id}'
    },
    {
      '#id': 'ap1',
      abbr: 'AP1',
      parentPath: '#ref{able.parentPath}.#ref{able.id}',
      permissions: [
        { accessLevel: 'leader', ability: 'add_promotion' },
        { accessLevel: 'clerk', ability: 'add_event' },
        { accessLevel: 'clerk', ability: 'edit_user' },
        { accessLevel: 'member', ability: 'view_event' }
      ],
      assignments: [
        {
          user: {
            lastName: 'Chicken',
            rank: { abbr: 'Lt.' }
          },
          position: {
            name: 'Platoon Leader',
            accessLevel: 'leader'
          }
        },
        {
          user: {
            '#id': 't5Dingo',
            lastName: 'Dingo',
            rank: { abbr: 'T/5' }
          },
          position: {
            name: 'Platoon Clerk',
            accessLevel: 'clerk'
          }
        }
      ]
    },
    {
      '#id': 'ap1s1',
      abbr: 'AP1S1',
      parentPath: '#ref{ap1.parentPath}.#ref{ap1.id}',
      permissions: [
        { accessLevel: 'member', ability: 'view_event' }
      ],
      assignments: [
        {
          user: {
            lastName: 'Antelope',
            rank: { abbr: 'Pvt.' }
          },
          position: {
            '#id': 'rifleman',
            name: 'Rifleman',
            accessLevel: 'member'
          }
        },
        {
          user: {
            lastName: 'Baboon',
            rank: { abbr: 'Sgt.' }
          },
          position: {
            name: 'Squad Leader',
            accessLevel: 'leader'
          }
        },
        {
          user: {
            '#ref': 't5Dingo'
          },
          position: {
            '#ref': 'rifleman'
          }
        }
      ]
    }
  ])
}
