exports.up = async function (knex) {
  await knex.schema.createTable('ranks', (table) => {
    table.increments('id').primary()
    table.string('abbr')
    table.string('name')
  })

  await knex.schema.createTable('users', (table) => {
    table.increments('id').primary()
    table.string('first_name')
    table.string('last_name')
    table.integer('rank_id').references('ranks.id').onDelete('set null')
  })

  await knex.schema.raw(`
    create extension if not exists ltree
  `)

  await knex.schema.createTable('units', (table) => {
    table.increments('id').primary()
    table.string('name')
    table.string('abbr').notNullable()
    table.specificType('parent_path', 'ltree')
  })

  await knex.schema.raw(`
    create type access_level as enum ('member', 'clerk', 'leader')
  `)

  await knex.schema.createTable('positions', (table) => {
    table.increments('id').primary()
    table.string('name')
    table.specificType('access_level', 'access_level').default('member')
  })

  await knex.schema.createTable('assignments', (table) => {
    table.increments('id').primary()
    table.integer('unit_id').references('units.id').onDelete('cascade')
    table.integer('user_id').references('users.id').onDelete('cascade')
    table.integer('position_id').references('positions.id').onDelete('set null')
  })

  await knex.schema.createTable('permissions', (table) => {
    table.increments('id').primary()
    table.integer('unit_id').references('units.id').onDelete('cascade')
    table.specificType('access_level', 'access_level').notNullable()
    table.string('ability').notNullable()
  })
}

exports.down = function (knex) {
  return Promise.all([
    knex.schema.raw('drop table if exists users cascade'),
    knex.schema.raw('drop table if exists ranks cascade'),
    knex.schema.raw('drop table if exists units cascade'),
    knex.schema.raw('drop table if exists positions cascade'),
    knex.schema.raw('drop table if exists assignments cascade'),
    knex.schema.raw('drop table if exists permissions cascade'),
    knex.schema.raw('drop type access_level')
  ])
}
