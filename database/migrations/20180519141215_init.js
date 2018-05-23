exports.up = async function (knex) {
  const accessLevels = ['member', 'clerk', 'leader']

  await knex.schema.createTable('ranks', (table) => {
    table.increments('id').primary()
    table.string('abbr')
    table.string('name')
  })

  await knex.schema.createTable('users', (table) => {
    table.increments('id').primary()
    table.string('first_name')
    table.string('last_name')
    table.integer('rank_id').references('ranks.id')
  })

  await knex.schema.createTable('units', (table) => {
    table.increments('id').primary()
    table.string('name')
    table.string('abbr').notNullable()
    table.specificType('parent_path', 'ltree')
  })

  await knex.schema.createTable('positions', (table) => {
    table.increments('id').primary()
    table.string('name')
    table.enu('access_level', accessLevels)
  })

  await knex.schema.createTable('assignments', (table) => {
    table.increments('id').primary()
    table.integer('unit_id').references('units.id')
    table.integer('user_id').references('users.id')
    table.integer('position_id').references('positions.id')
  })

  await knex.schema.createTable('permissions', (table) => {
    table.increments('id').primary()
    table.integer('unit_id').references('units.id')
    table.enu('access_level', accessLevels)
    table.string('ability').notNullable()
  })
}

exports.down = function (knex) {
  return Promise.all([
    knex.schema.dropTableIfExists('ranks'),
    knex.schema.dropTableIfExists('users'),
    knex.schema.dropTableIfExists('units'),
    knex.schema.dropTableIfExists('positions'),
    knex.schema.dropTableIfExists('assignments'),
    knex.schema.dropTableIfExists('permissions')
  ])
}
