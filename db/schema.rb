# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_08_04_153712) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "ltree"
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.bigint "unit_id"
    t.bigint "user_id"
    t.bigint "position_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position_id"], name: "index_assignments_on_position_id"
    t.index ["unit_id"], name: "index_assignments_on_unit_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "unit_id"
    t.integer "access_level"
    t.string "ability"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_permissions_on_unit_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "name"
    t.integer "access_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ranks", force: :cascade do |t|
    t.string "abbr"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", force: :cascade do |t|
    t.string "name"
    t.string "abbr"
    t.ltree "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abbr"], name: "index_units_on_abbr", unique: true
    t.index ["path"], name: "index_units_on_path", using: :gist
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "steamid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "rank_id"
    t.index ["rank_id"], name: "index_users_on_rank_id"
  end

  add_foreign_key "assignments", "positions"
  add_foreign_key "assignments", "units"
  add_foreign_key "assignments", "users"
  add_foreign_key "permissions", "units"
  add_foreign_key "users", "ranks"
end
