# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_20_063526) do
  create_table "__att1", id: { type: :integer, limit: 3, comment: "Attendance log ID", unsigned: true }, charset: "utf8mb3", comment: "Log of attendance", force: :cascade do |t|
    t.integer "event_id", limit: 3, null: false, comment: "Event ID", unsigned: true
    t.integer "member_id", limit: 3, null: false, comment: "Member ID", unsigned: true
    t.boolean "attended", comment: "Has member attended"
    t.boolean "excused", default: false, null: false, comment: "Has member posted absence"
    t.index ["event_id", "member_id"], name: "event and member", unique: true
    t.index ["event_id"], name: "Event ID"
    t.index ["member_id"], name: "User ID"
  end

  create_table "__eve1", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.datetime "datetime", precision: nil, null: false
    t.integer "unit_id", limit: 3, unsigned: true
    t.string "title", limit: 64, null: false
    t.string "type", limit: 32, null: false
    t.boolean "mandatory", default: false, null: false
    t.string "server", limit: 32, null: false
    t.integer "server_id", limit: 3, unsigned: true
    t.text "report", null: false
    t.integer "reporter_member_id", limit: 3, unsigned: true
    t.datetime "report_posting_date", precision: nil, comment: "Date of AAR posting"
    t.datetime "report_edit_date", precision: nil, comment: "Date of last AAR editing"
    t.index ["reporter_member_id"], name: "Reporter's ID"
    t.index ["server_id"], name: "Server ID"
    t.index ["unit_id"], name: "Unit ID"
  end

  create_table "abilities", id: { type: :integer, limit: 3, comment: "Ability's ID", unsigned: true }, charset: "utf8mb3", comment: "List of abilities", force: :cascade do |t|
    t.string "name", limit: 40, comment: "Ability's Name"
    t.string "abbr", limit: 24, null: false, comment: "Ability's Abbreviation"
    t.text "description", comment: "Detailed description of Ability"
  end

  create_table "assignments", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, comment: "User ID", unsigned: true
    t.integer "unit_id", limit: 3, null: false, unsigned: true
    t.string "position", limit: 64
    t.integer "position_id", limit: 3, default: 35, unsigned: true
    t.integer "access_level", limit: 2, default: 0
    t.date "start_date"
    t.date "end_date"
    t.index ["member_id", "unit_id", "position_id", "start_date"], name: "ttt", unique: true
    t.index ["member_id"], name: "Member ID"
    t.index ["position_id"], name: "position_id"
    t.index ["unit_id"], name: "Unit ID"
  end

  create_table "attendance", id: { type: :integer, limit: 3, comment: "Attendance log ID", unsigned: true }, charset: "utf8mb3", comment: "Log of attendance", force: :cascade do |t|
    t.integer "event_id", limit: 3, null: false, comment: "Event ID", unsigned: true
    t.integer "member_id", limit: 3, null: false, comment: "Member ID", unsigned: true
    t.boolean "attended", comment: "Has member attended"
    t.boolean "excused", default: false, null: false, comment: "Has member posted absence"
    t.index ["event_id", "member_id"], name: "event and member", unique: true
    t.index ["event_id"], name: "Event ID"
    t.index ["member_id"], name: "User ID"
  end

  create_table "audits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.json "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at", precision: nil
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "awardings", id: { type: :integer, limit: 3 }, charset: "utf8mb3", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, unsigned: true
    t.date "date", null: false
    t.integer "award_id", limit: 3, null: false, unsigned: true
    t.column "forum_id", "enum('PHPBB','SMF','Vanilla','Discourse')", comment: "Which forums"
    t.integer "topic_id", limit: 3, null: false, comment: "Negative means old forums"
    t.index ["award_id"], name: "Award ID"
    t.index ["member_id"], name: "User ID"
  end

  create_table "awards", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.string "code", limit: 16, default: "", null: false
    t.string "title", default: "", null: false
    t.text "description", null: false
    t.column "game", "enum('N/A','DH','DOD','Arma 3','RS','RS2','Squad')", null: false
    t.string "image", default: "", null: false
    t.string "thumbnail", default: "", null: false
    t.string "bar", default: "", null: false
    t.boolean "active", default: true, null: false
    t.integer "order", default: 0, null: false, unsigned: true
    t.string "display_filename"
    t.string "mini_filename"
    t.text "presentation_image_data"
    t.text "ribbon_image_data"
  end

  create_table "banlog", id: { type: :integer, limit: 3 }, charset: "utf8mb3", force: :cascade do |t|
    t.string "roid", limit: 24, null: false
    t.string "uid", limit: 24, null: false
    t.string "guid", limit: 40, null: false, comment: "GUID"
    t.string "handle", limit: 32
    t.string "ip", limit: 20
    t.date "date", null: false
    t.integer "id_admin", limit: 3, null: false, unsigned: true
    t.integer "id_poster", limit: 3, null: false, unsigned: true
    t.text "reason"
    t.text "comments"
    t.datetime "unbanned", precision: nil
    t.index ["id_admin"], name: "id_admin"
    t.index ["id_poster"], name: "id_poster"
  end

  create_table "class_permissions", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.column "class", "enum('Combat','Staff','Training')", comment: "Units table class"
    t.integer "ability_id", limit: 3, null: false, unsigned: true
    t.index ["ability_id"], name: "ability_id"
  end

  create_table "class_roles", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.column "class", "enum('Combat','Staff','Training')"
    t.integer "role_id", limit: 3, null: false, unsigned: true
  end

  create_table "countries", id: { type: :integer, limit: 2, comment: "Country ID" }, charset: "utf8mb3", force: :cascade do |t|
    t.string "abbr", limit: 2, null: false
    t.string "name", limit: 80, null: false
  end

  create_table "data_migrations", primary_key: "version", id: :string, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
  end

  create_table "delayed_jobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.index ["name"], name: "index_delayed_jobs_on_name"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "demerits", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, unsigned: true
    t.integer "author_member_id", limit: 3, unsigned: true
    t.column "forum_id", "enum('PHPBB','SMF','Vanilla','Discourse')", comment: "Which forums"
    t.integer "topic_id", limit: 3, null: false
    t.date "date", null: false
    t.text "reason"
    t.index ["author_member_id"], name: "Author ID"
    t.index ["member_id"], name: "User ID"
  end

  create_table "discharges", id: { type: :integer, limit: 3, comment: "Discharge's ID", unsigned: true }, charset: "utf8mb3", comment: "List of members' discharges", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, comment: "ID of discharged member ", unsigned: true
    t.date "date", null: false, comment: "Date of discharge"
    t.column "type", "enum('Honorable','General','Dishonorable')", default: "General", null: false, comment: "Type of discharge"
    t.text "reason", null: false, comment: "Description of discharging reason"
    t.boolean "was_reversed", default: false, null: false, comment: "Was the discharge reversed?"
    t.column "forum_id", "enum('PHPBB','SMF','Vanilla','Discourse')", comment: "Which forums"
    t.string "topic_id", limit: 20, null: false, comment: "ID of forum's topic"
    t.index ["member_id"], name: "Member ID"
  end

  create_table "eloas", id: { type: :integer, limit: 3, comment: "LOA's ID", unsigned: true }, charset: "utf8mb3", comment: "Extended Leaves of Absence", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, comment: "Member's ID", unsigned: true
    t.datetime "posting_date", precision: nil, null: false, comment: "Date of posting"
    t.date "start_date", null: false, comment: "Planned start date"
    t.date "end_date", null: false, comment: "Planned end date"
    t.date "return_date", comment: "Actual date of the return"
    t.text "reason", null: false, comment: "Reason for LOA"
    t.text "availability", comment: "Is member availaible during LOA"
    t.index ["member_id"], name: "Member ID"
  end

  create_table "enlistments", id: { type: :integer, limit: 3, comment: "Enlistment ID", unsigned: true }, charset: "utf8mb3", comment: "Enlistments into 29th ID", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, comment: "Enlistee's ID", unsigned: true
    t.date "date", null: false, comment: "Enlistment Date"
    t.integer "liaison_member_id", limit: 3, comment: "Member ID of Enlistment Liaison", unsigned: true
    t.column "forum_id", "enum('PHPBB','SMF','Vanilla','Discourse')", comment: "Which forums"
    t.integer "topic_id", limit: 3, comment: "ID of forums topic "
    t.integer "unit_id", limit: 3, comment: "Unit ID of Training Platoon", unsigned: true
    t.column "status", "enum('Pending','Accepted','Denied','Withdrawn','AWOL')", default: "Pending", null: false, comment: "Status of enlistment"
    t.string "first_name", limit: 30, null: false, comment: "Recruit's First Name"
    t.string "middle_name", limit: 1, comment: "Recruit's Middle Initial"
    t.string "last_name", limit: 40, null: false, comment: "Recruit's Last Name"
    t.string "age", limit: 8, null: false, comment: "Recruit's age"
    t.integer "country_id", limit: 2, comment: "Country ID"
    t.column "timezone", "enum('EST','GMT','PST','Any','None')", comment: "Prefered time zone"
    t.column "game", "enum('DH','RS','Arma 3','RS2','Squad')", default: "DH", comment: "Chosen game"
    t.string "ingame_name", limit: 60, null: false, comment: "In-game Name"
    t.string "steam_name", limit: 60, comment: "Steamfriends Name"
    t.text "steam_id", size: :tiny, null: false
    t.string "email", limit: 60, comment: "Working e-mail"
    t.text "experience", null: false
    t.string "recruiter", limit: 128, null: false
    t.integer "recruiter_member_id", limit: 3, comment: "Recruiter's MemberID", unsigned: true
    t.text "comments", null: false, comment: "Comments from Recruit"
    t.text "body", comment: "The enlistment papers"
    t.json "previous_units", default: -> { "(json_array())" }, null: false
    t.string "discord_username"
    t.index ["country_id"], name: "Country"
    t.index ["liaison_member_id"], name: "Liaison ID"
    t.index ["member_id"], name: "Member ID"
    t.index ["recruiter_member_id"], name: "Recruiter"
    t.index ["unit_id"], name: "Unit ID"
  end

  create_table "events", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.datetime "datetime", precision: nil, null: false
    t.integer "unit_id", limit: 3, unsigned: true
    t.string "title", limit: 64
    t.string "type", limit: 32, null: false
    t.boolean "mandatory", default: false, null: false
    t.string "server", limit: 32
    t.integer "server_id", limit: 3, unsigned: true
    t.text "report"
    t.integer "reporter_member_id", limit: 3, unsigned: true
    t.datetime "report_posting_date", precision: nil, comment: "Date of AAR posting"
    t.datetime "report_edit_date", precision: nil, comment: "Date of last AAR editing"
    t.datetime "starts_at", precision: nil, comment: "Start date/time in UTC"
    t.string "time_zone", default: "America/New_York", comment: "Priority time zone for this event, usually based on host unit"
    t.index ["reporter_member_id"], name: "Reporter's ID"
    t.index ["server_id"], name: "Server ID"
    t.index ["starts_at"], name: "index_events_on_starts_at"
    t.index ["unit_id"], name: "Unit ID"
  end

  create_table "finances", id: { type: :integer, limit: 3, comment: "Finance ID", unsigned: true }, charset: "utf8mb3", comment: "Finances Ledger", force: :cascade do |t|
    t.date "date", null: false, comment: "Date of entry"
    t.integer "member_id", limit: 3, comment: "Member ID", unsigned: true
    t.column "vendor", "enum('N/A','Game Servers','Branzone','Dreamhost','Nuclear Fallout','Other','Digital Ocean, Inc','Google')", null: false, comment: "Vendor of services"
    t.float "amount_received", comment: "Amount received"
    t.float "amount_paid", comment: "Amount paid"
    t.float "fee", comment: "Fee"
    t.column "forum_id", "enum('PHPBB','SMF','Vanilla','Discourse')", comment: "Which forums"
    t.string "topic_id", limit: 20, comment: "ID of forums' topic"
    t.text "notes", null: false, comment: "Additional notes"
    t.index ["member_id"], name: "Member ID"
  end

  create_table "log", id: { type: :integer, comment: "Log record ID", unsigned: true }, charset: "utf8mb3", comment: "Log of actions", force: :cascade do |t|
    t.string "table", limit: 20, null: false, comment: "Name of table"
    t.integer "table_record_id", limit: 3, null: false, comment: "ID of table's record", unsigned: true
    t.column "action", "enum('Add','Edit','Delete')", default: "Add", null: false, comment: "Action taken"
    t.timestamp "date", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Time of action"
    t.integer "member_id", limit: 3, null: false, unsigned: true
  end

  create_table "maintenance_tasks_runs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "task_name", null: false
    t.datetime "started_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.float "time_running", default: 0.0, null: false
    t.bigint "tick_count", default: 0, null: false
    t.bigint "tick_total"
    t.string "job_id"
    t.string "cursor"
    t.string "status", default: "enqueued", null: false
    t.string "error_class"
    t.string "error_message"
    t.text "backtrace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "arguments"
    t.integer "lock_version", default: 0, null: false
    t.text "metadata"
    t.index ["task_name", "status", "created_at"], name: "index_maintenance_tasks_runs", order: { created_at: :desc }
  end

  create_table "maps", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 40, null: false
    t.column "game", "enum('Arma 3','DH','RS','RS2','Squad')"
    t.text "descriptions", null: false
    t.column "type", "enum('A/A','A/D')", null: false
    t.column "style", "enum('Training','Infantry','Combined Arms','Tank')", null: false
    t.column "teams", "enum('Germany/USSR','Germany/USA','Germany/Commonwealth','Japan/USA')", null: false
    t.column "size", "enum('Small','Medium','Large')", null: false
    t.boolean "linearity", default: true, null: false
    t.text "notes", null: false
  end

  create_table "members", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.column "status", "enum('N/A','Cadet','Active Duty','Reservist','Retired','Discharged')"
    t.string "last_name", limit: 32, default: "", null: false
    t.string "first_name", limit: 32, default: "", null: false
    t.string "middle_name", limit: 32, default: ""
    t.string "name_prefix", limit: 8
    t.integer "country_id", limit: 2, comment: "Country ID"
    t.string "city", limit: 32
    t.integer "rank_id", limit: 3, default: 1, null: false, unsigned: true
    t.integer "primary_assignment_id", limit: 3, unsigned: true
    t.text "steam_id", size: :tiny
    t.string "email", default: ""
    t.column "im_type", "enum('AIM','''MSN','''ICQ','''YIM','''Skype')", comment: "Instant Messenger Type"
    t.string "im_handle", limit: 100, comment: "Instant Messenger Handle"
    t.integer "vanilla_forum_member_id", limit: 3, unsigned: true
    t.integer "forum_member_id", limit: 3, unsigned: true
    t.string "time_zone", default: "UTC"
    t.string "slug"
    t.text "service_coat_data"
    t.index ["country_id"], name: "CountryID"
    t.index ["forum_member_id"], name: "index_members_on_forum_member_id", unique: true
    t.index ["primary_assignment_id"], name: "Assignment"
    t.index ["rank_id"], name: "Rank"
    t.index ["slug"], name: "index_members_on_slug", unique: true
  end

  create_table "notes", id: { type: :integer, limit: 3, comment: "Note's ID", unsigned: true }, charset: "utf8mb3", comment: "Notes", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, comment: "Member ID of note's subject", unsigned: true
    t.integer "author_member_id", limit: 3, null: false, comment: "Member ID of note's author", unsigned: true
    t.datetime "date_add", precision: nil, null: false, comment: "Date & Time of adding"
    t.datetime "date_mod", precision: nil, comment: "Date & Time of last modification"
    t.column "access", "enum('Public','Members Only','Personal','Squad Level','Platoon Level','Company Level','Battalion HQ','Officers Only','Military Police','Lighthouse')", null: false, comment: "Access level"
    t.string "subject", limit: 120, null: false, comment: "Note's subject"
    t.text "content", null: false, comment: "Note's text"
    t.index ["author_member_id"], name: "Author ID"
    t.index ["member_id"], name: "Member ID"
  end

  create_table "passes", id: { type: :integer, comment: "Pass ID", unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, comment: "Receiver's Member ID", unsigned: true
    t.integer "author_id", limit: 3, null: false, comment: "Author's Member ID", unsigned: true
    t.integer "recruit_id", limit: 3, comment: "Recruit's Member ID (pass for recruiting)", unsigned: true
    t.date "add_date", comment: "Date of adding the WP record"
    t.date "start_date", null: false, comment: "Data of start "
    t.date "end_date", null: false, comment: "Date of end"
    t.column "type", "enum('Recruitment','Recurring Donation','Award','Other')", comment: "Type of Weapon Pass"
    t.text "reason", null: false, comment: "Reason for pass"
    t.index ["author_id"], name: "AuthorID"
    t.index ["member_id"], name: "MemberID"
    t.index ["recruit_id"], name: "RecruitID"
  end

  create_table "positions", id: { type: :integer, limit: 3, comment: "ID", unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 250, null: false, comment: "Name of position"
    t.boolean "active", default: true, null: false, comment: "Is position active"
    t.integer "order", limit: 1, default: 0, null: false, unsigned: true
    t.text "description"
    t.integer "access_level", limit: 2, default: 0, null: false, comment: "is access granted?"
    t.column "AIT", "enum('Leadership','Rifle','Submachine Gun','Automatic Rifle','Combat Engineer','Machine Gun','Armor','Mortar','Pilot','Sniper','N/A','Grenadier')", default: "N/A", null: false, comment: "AIT associated with position"
  end

  create_table "promotions", id: { type: :integer, limit: 3, comment: "Promotion ID", unsigned: true }, charset: "utf8mb3", comment: "V: Users <-> Rank", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, comment: "ID of promoted member", unsigned: true
    t.date "date", null: false, comment: "Date of promotion"
    t.integer "old_rank_id", limit: 3, unsigned: true
    t.integer "new_rank_id", limit: 3, null: false, comment: "Rank after promotion", unsigned: true
    t.column "forum_id", "enum('PHPBB','SMF','Vanilla','Discourse')", comment: "ID of forum where promotion was posted"
    t.integer "topic_id", limit: 3, null: false, comment: "ID of forums topic "
    t.index ["member_id"], name: "User ID"
    t.index ["new_rank_id"], name: "New Rank"
    t.index ["old_rank_id"], name: "Old Rank"
  end

  create_table "qualifications", id: { type: :integer, limit: 3 }, charset: "utf8mb3", comment: "V: Users <-> Standards", force: :cascade do |t|
    t.integer "member_id", limit: 3, null: false, unsigned: true
    t.integer "standard_id", limit: 3, null: false, unsigned: true
    t.date "date"
    t.integer "author_member_id", limit: 3, unsigned: true
    t.index ["author_member_id"], name: "Author"
    t.index ["member_id", "standard_id"], name: "MemberStandard", unique: true
    t.index ["member_id"], name: "User ID"
    t.index ["standard_id"], name: "AIT Standard ID"
  end

  create_table "ranks", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 32, default: "", null: false
    t.string "abbr", limit: 8, default: "", null: false
    t.string "grade", limit: 4
    t.string "filename", limit: 32, default: ""
    t.integer "order", limit: 2, null: false
    t.text "description"
    t.text "image_data"
  end

  create_table "restricted_names", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 40, null: false
    t.integer "member_id", limit: 3, null: false, unsigned: true
    t.index ["member_id"], name: "Member", unique: true
  end

  create_table "schedules", id: { type: :integer, limit: 3, comment: "Schedule ID", unsigned: true }, charset: "utf8mb3", comment: "Schedule of regular events", force: :cascade do |t|
    t.integer "unit_id", limit: 3, null: false, comment: "Unit ID", unsigned: true
    t.string "type", limit: 40, null: false, comment: "Type of event"
    t.integer "server_id", limit: 3, null: false, comment: "Server ID", unsigned: true
    t.boolean "mandatory", null: false, comment: "Is mandatory?"
    t.column "day_of_week", "enum('0','1','2','3','4','5','6')", null: false, comment: "Day of week"
    t.time "hour_of_day", null: false, comment: "Time of drill (UTC)"
    t.index ["server_id"], name: "Server ID"
    t.index ["unit_id"], name: "Unit ID"
  end

  create_table "servers", id: { type: :integer, limit: 3, comment: "Server ID", unsigned: true }, charset: "utf8mb3", comment: "List of 29th servers", force: :cascade do |t|
    t.string "name", limit: 40, null: false, comment: "Server Name"
    t.string "abbr", limit: 4, null: false, comment: "Abbreviation of Server Name"
    t.string "address", limit: 15, null: false, comment: "IP address of server"
    t.integer "port", limit: 3, null: false, comment: "Port of Server"
    t.column "game", "enum('DH','Arma 3','RS','RS2','Squad')", default: "DH", null: false, comment: "Type of game "
    t.boolean "active", null: false, comment: "Is server active"
    t.string "battle_metrics_id", limit: 16
  end

  create_table "special_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "special_attribute", null: false
    t.integer "role_id", null: false
    t.column "forum_id", "enum('Vanilla','Discourse')", null: false
  end

  create_table "standards", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", comment: "Standards required to achieve a badge for AIT", force: :cascade do |t|
    t.column "weapon", "enum('EIB','Rifle','Automatic Rifle','Machine Gun','Armor','Sniper','Mortar','SLT','Combat Engineer','Submachine Gun','Pilot','Grenadier')", default: "Rifle", null: false
    t.column "game", "enum('DH','RS','Arma 3','RS2','Squad')", default: "DH", null: false
    t.column "badge", "enum('N/A','Marksman','Sharpshooter','Expert')", default: "Sharpshooter", null: false
    t.text "description", null: false
    t.text "details"
  end

  create_table "unit_permissions", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.integer "unit_id", limit: 3, null: false, unsigned: true
    t.integer "access_level", limit: 2, default: 1, null: false
    t.integer "ability_id", limit: 3, null: false, comment: "ID of ability", unsigned: true
    t.index ["ability_id"], name: "Ability ID"
    t.index ["unit_id", "access_level", "ability_id"], name: "combo", unique: true
    t.index ["unit_id"], name: "Unit ID"
  end

  create_table "unit_roles", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.integer "unit_id", limit: 3, unsigned: true
    t.integer "access_level", limit: 2, default: 0, null: false
    t.integer "role_id", limit: 3, null: false, unsigned: true
    t.column "forum_id", "enum('Vanilla','Discourse')", null: false
    t.index ["unit_id", "role_id", "forum_id"], name: "index_unit_roles_on_unit_id_and_role_id_and_forum_id", unique: true
  end

  create_table "units", id: { type: :integer, limit: 3, unsigned: true }, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "abbr", limit: 32, null: false
    t.string "old_path", limit: 32
    t.string "path", limit: 32, null: false
    t.integer "order", default: 0, null: false
    t.column "game", "enum('DH','RS','Arma 3','RS2','Squad')", comment: "Game "
    t.string "timezone", limit: 3
    t.column "class", "enum('Combat','Staff','Training')", default: "Training", null: false, comment: "Type of unit"
    t.boolean "active", default: true, null: false
    t.string "steam_group_abbr", limit: 30, comment: "Abbreviation of Unit's Steam Group"
    t.string "slogan", limit: 200, comment: "Unit's Slogan"
    t.string "logo", limit: 40, comment: "Filename of a unit's logo"
    t.string "nickname", limit: 40
    t.text "aar_template", comment: "Template for AAR"
    t.string "ancestry"
    t.column "classification", "enum('Combat','Staff','Training')", default: "Training", null: false
    t.text "logo_data"
    t.string "slug"
    t.index ["ancestry"], name: "index_units_on_ancestry"
    t.index ["slug"], name: "index_units_on_slug", unique: true
  end

  create_table "usertracking", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "session_id", limit: 100, null: false
    t.string "user_identifier", null: false
    t.text "request_uri", null: false
    t.string "request_method", limit: 16, null: false
    t.datetime "datetime", precision: nil, null: false
    t.string "client_ip", limit: 50, null: false
    t.text "client_user_agent", null: false
    t.text "referer_page", null: false
  end

  add_foreign_key "assignments", "members", name: "assignments_ibfk_5", on_update: :cascade
  add_foreign_key "assignments", "positions", name: "assignments_ibfk_4", on_update: :cascade
  add_foreign_key "assignments", "units", name: "assignments_ibfk_2", on_update: :cascade
  add_foreign_key "attendance", "events", name: "attendance_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attendance", "members", name: "attendance_ibfk_2", on_update: :cascade
  add_foreign_key "awardings", "awards", name: "awardings_ibfk_2", on_update: :cascade
  add_foreign_key "awardings", "members", name: "awardings_ibfk_3", on_update: :cascade
  add_foreign_key "class_permissions", "abilities", name: "class_permissions_ibfk_1", on_update: :cascade
  add_foreign_key "demerits", "members", column: "author_member_id", name: "demerits_ibfk_2", on_update: :cascade
  add_foreign_key "demerits", "members", name: "demerits_ibfk_1", on_update: :cascade
  add_foreign_key "discharges", "members", name: "discharges_ibfk_1", on_update: :cascade
  add_foreign_key "eloas", "members", name: "eloas_ibfk_1", on_update: :cascade
  add_foreign_key "enlistments", "countries", name: "enlistments_ibfk_6", on_update: :cascade
  add_foreign_key "enlistments", "members", column: "liaison_member_id", name: "enlistments_ibfk_2", on_update: :cascade
  add_foreign_key "enlistments", "members", column: "recruiter_member_id", name: "enlistments_ibfk_7", on_update: :cascade
  add_foreign_key "enlistments", "members", name: "enlistments_ibfk_1", on_update: :cascade
  add_foreign_key "enlistments", "units", name: "enlistments_ibfk_5", on_update: :cascade
  add_foreign_key "events", "members", column: "reporter_member_id", name: "events_ibfk_5", on_update: :cascade
  add_foreign_key "events", "servers", name: "events_ibfk_4", on_update: :cascade
  add_foreign_key "events", "units", name: "events_ibfk_3", on_update: :cascade
  add_foreign_key "finances", "members", name: "finances_ibfk_1", on_update: :cascade
  add_foreign_key "members", "countries", name: "members_ibfk_2", on_update: :cascade
  add_foreign_key "members", "ranks", name: "members_ibfk_3", on_update: :cascade
  add_foreign_key "notes", "members", column: "author_member_id", name: "notes_ibfk_2", on_update: :cascade
  add_foreign_key "notes", "members", name: "notes_ibfk_1", on_update: :cascade
  add_foreign_key "passes", "members", column: "author_id", name: "passes_ibfk_2", on_update: :cascade
  add_foreign_key "passes", "members", name: "passes_ibfk_1", on_update: :cascade
  add_foreign_key "promotions", "members", name: "promotions_ibfk_5", on_update: :cascade
  add_foreign_key "promotions", "ranks", column: "new_rank_id", name: "promotions_ibfk_7", on_update: :cascade
  add_foreign_key "promotions", "ranks", column: "old_rank_id", name: "promotions_ibfk_6", on_update: :cascade
  add_foreign_key "qualifications", "members", column: "author_member_id", name: "qualifications_ibfk_6", on_update: :cascade
  add_foreign_key "qualifications", "members", name: "qualifications_ibfk_4", on_update: :cascade
  add_foreign_key "qualifications", "standards", name: "qualifications_ibfk_5", on_update: :cascade, on_delete: :cascade
  add_foreign_key "restricted_names", "members", name: "restricted_names_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "schedules", "servers", name: "schedules_ibfk_2", on_update: :cascade
  add_foreign_key "schedules", "units", name: "schedules_ibfk_1", on_update: :cascade
  add_foreign_key "unit_roles", "units", name: "unit_roles_ibfk_1", on_update: :cascade
end
