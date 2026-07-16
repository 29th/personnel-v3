# Generates a representative, PII-free development dataset.
#
# The shape of this data (org structure, career/churn patterns, rank pyramid,
# event cadence, attendance rates) is modelled on aggregate statistics from a
# production database dump, so a seeded environment feels like the real app.
# All names, emails, steam IDs and free text are fake. Reference tables
# (ranks, positions, abilities, awards, countries, AIT standards) are real,
# non-personal config extracted from production into db/seeds/data/.
#
# Seeding is deterministic for a given day: the RNG is fixed, but dates are
# generated relative to Date.current so "active" data stays recent.
#
# Usage: bin/rails db:seed (also runs via db:prepare when the db is created)

return if Rails.env.test?

if User.exists?
  abort("Refusing to seed: the database already contains data. " \
        "Run `bin/rails db:reset` to drop, recreate and reseed.")
end

require "faker"

srand(29)
Faker::Config.random = Random.new(29)

# Auditing every generated record would triple the insert volume for no value
Audited.auditing_enabled = false

started_at = Time.current
Dir[Rails.root.join("db/seeds/[0-9]*.rb")].sort.each do |file|
  puts "== #{File.basename(file)}"
  load file
end
Audited.auditing_enabled = true

puts <<~SUMMARY
  Seeded in #{(Time.current - started_at).round(1)}s:
    #{Unit.count} units (#{Unit.active.count} active)
    #{User.count} users (#{User.active.count} with an active assignment)
    #{Assignment.count} assignments, #{Enlistment.count} enlistments, #{Discharge.count} discharges
    #{Promotion.count} promotions, #{UserAward.count} awardings, #{AITQualification.count} qualifications
    #{Event.count} events, #{AttendanceRecord.count} attendance records
SUMMARY

# In development you can use the navbar's "Sign in (dev)" button with a
# forum_member_id to act as any seeded user
persona = ->(position_name) do
  user = Assignment.active.joins(:position)
    .find_by(positions: {name: position_name})&.user
  puts "    #{user.forum_member_id}  #{user.short_name} (#{position_name})" if user
end
puts "  Dev sign-in personas (forum_member_id):"
["Regiment Commander", "Commanding Officer", "Squad Leader", "Rifleman", "Recruit"]
  .each { |position_name| persona.call(position_name) }
