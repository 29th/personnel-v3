# Three years of events and attendance plus two weeks of upcoming events.
# Cadence mirrors production: each squad drills twice a week (~100
# events/year), platoons/companies/battalions at wider intervals, and
# training platoons run BCT sessions during their month. Attendance outcome
# rates match production: ~63% attended, ~20% excused, ~17% absent.

HISTORY_WEEKS = 156
FUTURE_DAYS = 14

# [member_id, start, end] intervals per unit, for computing who was expected
# at an event on a given date (includes historical members' stints)
assignments_by_unit = Hash.new { |h, k| h[k] = [] }
Assignment.pluck(:unit_id, :member_id, :start_date, :end_date).each do |unit_id, member_id, start_date, end_date|
  assignments_by_unit[unit_id] << [member_id, start_date, end_date]
end
leaders_by_unit = Hash.new { |h, k| h[k] = [] }
Assignment.joins(:position).where(positions: {access_level: 10})
  .pluck(:unit_id, :member_id, :start_date, :end_date)
  .each do |unit_id, member_id, start_date, end_date|
    leaders_by_unit[unit_id] << [member_id, start_date, end_date]
  end

def members_on(intervals_by_unit, unit_ids, date)
  unit_ids.flat_map do |unit_id|
    intervals_by_unit[unit_id]
      .select { |_, start_date, end_date| start_date && start_date <= date && (end_date.nil? || end_date > date) }
      .map(&:first)
  end.uniq
end

active_servers = Server.where(active: true).to_a

def pick_server(active_servers, game, preferred_abbrs)
  candidates = game ? active_servers.select { |s| s.game == game } : active_servers
  candidates = active_servers if candidates.empty?
  preferred_abbrs.each do |abbr|
    match = candidates.find { |s| s.abbr == abbr }
    return match if match
  end
  candidates.sample
end

@event_id = 0
@event_rows = []
@attendance_rows = []

def seed_event!(unit:, type:, date:, hour_utc:, time_zone:, server:,
  roster:, leaders:, mandatory: true)
  starts_at = Time.utc(date.year, date.month, date.day, hour_utc)
  past = starts_at < Time.current
  reporter_id = leaders.sample || roster.sample
  has_report = past && rand < 0.85

  @event_rows << {
    id: (@event_id += 1),
    datetime: starts_at.in_time_zone("Eastern Time (US & Canada)").strftime("%F %R"),
    unit_id: unit.id, title: nil, type:, mandatory:,
    server: nil, server_id: server.id,
    report: has_report ? Faker::Lorem.paragraph(sentence_count: rand(2..5)) : nil,
    reporter_member_id: has_report ? reporter_id : nil,
    report_posting_date: has_report ? starts_at + rand(6..30).hours : nil,
    report_edit_date: nil,
    starts_at:, time_zone:
  }
  return unless past

  roster.each do |member_id|
    attended = rand < 0.63
    @attendance_rows << {event_id: @event_id, member_id:, attended:,
                         excused: !attended && rand < 0.55}
  end
end

# Weekly drill schedule per squad, staggered so squads don't all drill on the
# same nights. GMT squads drill at European-friendly hours.
weekday_pairs = [[2, 6], [3, 0], [4, 6], [1, 5]]
first_week = Date.current.beginning_of_week - HISTORY_WEEKS.weeks
horizon = Date.current + FUTURE_DAYS

Unit.active.combat.where("name LIKE ?", "%Squad%").order(:abbr).each_with_index do |squad, i|
  hour_utc = squad.gmt? ? 19 : 1
  time_zone = squad.gmt? ? "London" : "Eastern Time (US & Canada)"
  server = pick_server(active_servers, squad.game, %w[sq sqd plt co])
  roster_units = [squad.id]

  (0..HISTORY_WEEKS + 2).each do |week|
    week_start = first_week + week.weeks
    weekday_pairs[i % weekday_pairs.size].each do |wday|
      date = week_start + ((wday - week_start.wday) % 7)
      next if date > horizon
      seed_event!(unit: squad, type: "Squad Drills", date:, hour_utc:,
        time_zone:, server:,
        roster: members_on(assignments_by_unit, roster_units, date),
        leaders: members_on(leaders_by_unit, roster_units, date))
    end
  end
end

# Platoon drills every 4 weeks, company drills every 6, battalion quarterly
{"%P_ HQ" => ["Platoon Drills", 4, %w[plt co]],
 "%Co. HQ" => ["Company Drills", 6, %w[co bn]],
 "%Bn. HQ" => ["Battalion Drills", 13, %w[bn co]]}.each do |pattern, (type, cadence_weeks, server_abbrs)|
  Unit.active.combat.where("abbr LIKE ?", pattern).each_with_index do |unit, i|
    subtree_ids = unit.subtree_ids
    server = pick_server(active_servers, unit.game, server_abbrs)
    week = i % cadence_weeks # stagger
    while week <= HISTORY_WEEKS + 2
      date = first_week + week.weeks + 5 # Saturdays
      week += cadence_weeks
      next if date > horizon
      seed_event!(unit:, type:, date:, hour_utc: 20,
        time_zone: "Eastern Time (US & Canada)", server:,
        roster: members_on(assignments_by_unit, subtree_ids, date),
        leaders: members_on(leaders_by_unit, subtree_ids, date))
    end
  end
end

# Occasional non-mandatory public scrimmages at company level
Unit.active.combat.where("abbr LIKE ?", "%Co. HQ").each do |company|
  subtree_ids = company.subtree_ids
  server = pick_server(active_servers, company.game, %w[pub eu co])
  (0..HISTORY_WEEKS).step(10) do |week|
    date = first_week + week.weeks + 6
    seed_event!(unit: company, type: "Public Scrimmage", date:, hour_utc: 21,
      time_zone: "Eastern Time (US & Canada)", server:, mandatory: false,
      roster: members_on(assignments_by_unit, subtree_ids, date).sample(30),
      leaders: members_on(leaders_by_unit, subtree_ids, date))
  end
end

# Basic Combat Training: three sessions a week during each platoon's month
TRAINING_PLATOONS.each do |tp|
  unit = tp[:unit]
  server = pick_server(active_servers, unit.game, %w[bct plt co])
  roster_units = [unit.id]
  (0..3).each do |week|
    [1, 3, 5].each do |offset|
      date = tp[:month].beginning_of_week + week.weeks + offset
      next if date > horizon
      roster = members_on(assignments_by_unit, roster_units, date)
      next if roster.empty?
      seed_event!(unit:, type: "Basic Combat Training", date:, hour_utc: 1,
        time_zone: "Eastern Time (US & Canada)", server:,
        roster:, leaders: [])
    end
  end
end

@event_rows.each_slice(2_000) { |slice| Event.insert_all(slice) }
@attendance_rows.each_slice(5_000) { |slice| AttendanceRecord.insert_all(slice) }

puts "   events: #{@event_rows.size}, attendance records: #{@attendance_rows.size}"
