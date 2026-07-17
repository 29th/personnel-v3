# Members and their careers. Modelled on production patterns:
# - an active roster of ~270 filling every squad, HQ and staff corps, with
#   tenure-appropriate ranks and promotion history (a bottom-heavy pyramid)
# - ~1,100 historical members over 3 years reflecting the real enlistment
#   funnel (~52% accepted, ~21% withdrawn, ~17% AWOL, ~10% denied), most of
#   whom churn out within weeks and end discharged General/Honorable
# - awards, AIT qualifications, ELOAs, passes, notes and (rare) demerits at
#   production-like per-member rates

RANKS = Rank.all.index_by(&:abbr)
POSITIONS = Position.all.index_by(&:name)
COUNTRY_IDS = Country.pluck(:abbr, :id).to_h

# Ranks are earned in ladder order; clerks sometimes top out as technicians
RANK_LADDER = ["Rec.", "Pvt.", "PFC", "Cpl.", "Sgt.", "SSgt.", "TSgt.",
  "MSgt.", "FSgt.", "2Lt.", "1Lt.", "Cpt.", "Maj.", "Lt. Col.", "Col."]
TECHNICIAN_LADDER = ["Rec.", "Pvt.", "PFC", "T/5", "T/4", "T/3"]

USER_TIME_ZONES = ["Eastern Time (US & Canada)", "Central Time (US & Canada)",
  "Pacific Time (US & Canada)", "London", "Amsterdam", "Sydney", "UTC"]
WEIGHTED_COUNTRIES = %w[US US US US US GB GB CA CA AU DE NL SE PL FR NO]

BCT_DAYS = 28 # basic training length; drives TP assignment windows

@next_forum_member_id = 1000
@member_profiles = [] # metadata consumed by the enlistment/extras passes

def fake_steam_id = "7656119#{format("%010d", rand(10_000_000_000))}"

# Which forum software hosted the paper trail at that point in history
def forum_for(date)
  (date < 4.years.ago.to_date) ? "Vanilla" : "Discourse"
end

def fake_topic_id = rand(1_000..99_999)

def training_platoon_for(date, game)
  month = date.beginning_of_month
  candidates = TRAINING_PLATOONS.select { |tp| tp[:month] == month }
  exact = candidates.find { |tp| tp[:game] == game }
  (exact || candidates.first ||
    TRAINING_PLATOONS.min_by { |tp| (tp[:month] - month).abs })[:unit]
end

def sample_tenure_days
  case rand
  when 0..0.20 then rand(30..120)
  when 0.20..0.60 then rand(120..550)
  when 0.60..0.85 then rand(550..1_100)
  else rand(1_100..2_900)
  end
end

def create_user!(rank_abbr:, enlist_date:, game:)
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  User.create!(
    first_name:, last_name:,
    middle_name: (rand < 0.3) ? ("A".."Z").to_a.sample : nil,
    rank: RANKS.fetch(rank_abbr),
    steam_id: fake_steam_id,
    email: Faker::Internet.email(name: "#{first_name} #{last_name}"),
    time_zone: USER_TIME_ZONES.sample,
    country_id: (rand < 0.9) ? COUNTRY_IDS[WEIGHTED_COUNTRIES.sample] : nil,
    forum_member_id: (@next_forum_member_id += 1),
    vanilla_forum_member_id: (enlist_date < 4.years.ago.to_date) ? @next_forum_member_id : nil
  ).tap do |user|
    @member_profiles << {user:, enlist_date:, game:, career_end: nil,
                         graduated: true, enlist_status: :accepted}
  end
end

@promotion_rows = []

# Promotions climbing the ladder from Recruit to target_abbr, spread across
# the member's service. Median gap between promotions in production is ~176
# days (p25 106, p75 349).
def plan_promotions!(user, target_abbr, enlist_date, end_date)
  ladder = TECHNICIAN_LADDER.include?(target_abbr) ? TECHNICIAN_LADDER : RANK_LADDER
  rungs = ladder[1..ladder.index(target_abbr)] || []
  return if rungs.empty?

  graduation = enlist_date + BCT_DAYS
  span = (end_date - graduation).to_i
  avg_gap = [span / rungs.size, 1].max
  date = graduation
  previous = RANKS.fetch("Rec.")
  rungs.each_with_index do |abbr, i|
    date += (i.zero? ? 0 : (avg_gap * rand(0.6..1.4)).to_i)
    date = [date, end_date].min
    rank = RANKS.fetch(abbr)
    @promotion_rows << {member_id: user.id, date:, old_rank_id: previous.id,
                        new_rank_id: rank.id, forum_id: forum_for(date),
                        topic_id: fake_topic_id}
    previous = rank
  end
end

def assign!(user, unit, position_name, start_date, end_date = nil)
  Assignment.create!(user:, unit:, position: POSITIONS.fetch(position_name),
    start_date:, end_date:)
end

# An active member: enlisted `tenure_days` ago, did BCT, now holds `position`
# in `unit` (with an optional earlier assignment elsewhere in the company)
def seed_active_member!(unit:, position:, rank:, tenure_days:, previous_unit: nil)
  enlist_date = Date.current - tenure_days
  user = create_user!(rank_abbr: rank, enlist_date:, game: unit.game || "squad")

  tp = training_platoon_for(enlist_date, unit.game)
  assign!(user, tp, "Recruit", enlist_date + 2, enlist_date + BCT_DAYS)

  current_start = enlist_date + BCT_DAYS
  if previous_unit && tenure_days > 540
    transfer_date = Date.current - rand(90..360)
    assign!(user, previous_unit, "Rifleman", current_start, transfer_date)
    current_start = transfer_date
  end
  assign!(user, unit, position, current_start)

  plan_promotions!(user, rank, enlist_date, Date.current - rand(0..60))
  user
end

active_squads = Unit.active.combat.where("name LIKE ?", "%Squad%").order(:abbr)
squad_member_positions = ["Rifleman"] * 5 + ["Grenadier", "Submachine Gunner",
  "Combat Engineer", "First Class Automatic Rifleman",
  "Second Class Automatic Rifleman"]

active_squads.each do |squad|
  siblings = squad.siblings.where("name LIKE ?", "%Squad%").where.not(id: squad.id)
  seed_active_member!(unit: squad, position: "Squad Leader",
    rank: %w[Sgt. SSgt.].sample, tenure_days: rand(700..2_500))
  seed_active_member!(unit: squad, position: "Asst. Squad Leader",
    rank: %w[Cpl. Sgt.].sample, tenure_days: rand(400..1_500))
  rand(6..9).times do
    tenure_days = sample_tenure_days
    rank = if tenure_days < 240
      "Pvt."
    elsif tenure_days < 550
      "PFC"
    else
      ["Cpl.", "Cpl.", "T/5", "Sgt."].sample
    end
    seed_active_member!(unit: squad, position: squad_member_positions.sample,
      rank:, tenure_days:,
      previous_unit: (rand < 0.25) ? siblings.sample : nil)
  end
end

Unit.active.combat.where("abbr LIKE ?", "%P_ HQ").find_each do |platoon|
  seed_active_member!(unit: platoon, position: "Platoon Leader",
    rank: %w[2Lt. 1Lt.].sample, tenure_days: rand(900..2_700))
  seed_active_member!(unit: platoon, position: "Platoon Sergeant",
    rank: %w[TSgt. MSgt.].sample, tenure_days: rand(900..2_700))
  seed_active_member!(unit: platoon, position: "Platoon Clerk",
    rank: "T/5", tenure_days: rand(250..1_100))
  if rand < 0.6
    seed_active_member!(unit: platoon, position: "Platoon Sniper",
      rank: "PFC", tenure_days: rand(250..1_100))
  end
end

Unit.active.combat.where("abbr LIKE ?", "%Co. HQ").find_each do |company|
  seed_active_member!(unit: company, position: "Commanding Officer",
    rank: "Cpt.", tenure_days: rand(1_400..2_900))
  seed_active_member!(unit: company, position: "Executive Officer",
    rank: "1Lt.", tenure_days: rand(1_100..2_700))
  seed_active_member!(unit: company, position: "First Sergeant",
    rank: "FSgt.", tenure_days: rand(1_100..2_700))
  seed_active_member!(unit: company, position: "Company Clerk",
    rank: "T/4", tenure_days: rand(400..1_400))
end

Unit.active.combat.where("abbr LIKE ?", "%Bn. HQ").find_each do |battalion|
  seed_active_member!(unit: battalion, position: "Battalion Commander",
    rank: %w[Maj. Lt.\ Col.].sample, tenure_days: rand(1_800..2_900))
  seed_active_member!(unit: battalion, position: "Battalion Executive Officer",
    rank: "Cpt.", tenure_days: rand(1_400..2_700))
  seed_active_member!(unit: battalion, position: "Battalion SNCO",
    rank: "Sgt. Maj", tenure_days: rand(1_400..2_700))
end

regiment = Unit.find_root
seed_active_member!(unit: regiment, position: "Regiment Commander",
  rank: "Col.", tenure_days: rand(2_200..2_900))
seed_active_member!(unit: regiment, position: "Regiment SNCO",
  rank: "CSM", tenure_days: rand(1_800..2_900))
seed_active_member!(unit: regiment, position: "Regiment Clerk",
  rank: "Sgt.", tenure_days: rand(700..1_800))

reserve = Unit.find_by!(abbr: "Rsrv S1")
seed_active_member!(unit: reserve, position: "Chief Reservist",
  rank: "SSgt.", tenure_days: rand(1_800..2_900))
4.times do
  seed_active_member!(unit: reserve, position: "Reservist",
    rank: %w[Cpl. Sgt. SSgt.].sample, tenure_days: rand(1_100..2_900))
end

# Staff corps are mostly dual-hatted combat members plus a couple of
# staff-only veterans; gives the 1-3 concurrent assignments seen in prod
STAFF_POSITIONS = {
  "Adj" => ["Chief of Adjutant Corps", "Adjutant Clerk", "ELOA Adjutant", "Attendance Adjutant"],
  "Fin" => ["Chief Finance Officer", "Finance Officer", "Finance Clerk"],
  "Quart" => ["Chief of Quartermaster Corps", "Quartermaster"],
  "MP" => ["Chief of Military Police Corps", "Military Police Officer", "Military Police Officer"],
  "Civ" => ["Chief of Civil Affairs Corps", "War Correspondent - SQ", "Print Journalist"],
  "LH" => ["Chief of Lighthouse Corps", "Enlistment Liaison - SQ", "Enlistment Liaison - A3",
    "Enlistment Liaison - RS2", "Drill Instructor - SQ", "Asst. Drill Instructor - A3"],
  "Oper" => ["Chief of Operations Corps", "Scrimmage Admin"],
  "Sig" => ["Chief of Signal Corps", "Signal Corps Community Contact", "Signal Corps Clerk"],
  "Eng" => ["Chief of Engineer Corps", "Code Technician", "Web Technician"],
  "Med" => ["Chief of Medical Corps", "Medical Technician"],
  "Ord" => ["Chief of Ordnance Corps", "Ordnance Instructor", "Ordnance Instructor"]
}

nco_pool = @member_profiles
  .select { |p| p[:user].rank.order >= RANKS.fetch("Cpl.").order }
  .shuffle

STAFF_POSITIONS.each do |abbr, position_names|
  corps = Unit.find_by!(abbr:)
  position_names.each do |position_name|
    profile = nco_pool.pop
    break if profile.nil?
    start = [profile[:enlist_date] + rand(200..400), Date.current - 30].min
    assign!(profile[:user], corps, position_name, start)
  end
end

# A couple of staff-only veterans (no combat assignment)
2.times do
  enlist_date = Date.current - rand(1_500..2_900)
  user = create_user!(rank_abbr: "SSgt.", enlist_date:, game: "dh")
  assign!(user, training_platoon_for(enlist_date, :dh), "Recruit",
    enlist_date + 2, enlist_date + BCT_DAYS)
  assign!(user, Unit.find_by!(abbr: "Adj"), "Senior Adjutant Clerk", Date.current - rand(300..900))
  plan_promotions!(user, "SSgt.", enlist_date, Date.current - rand(200..400))
end

# Server admins hold broad permissions via the Temporary Admins unit
admins = Unit.find_by!(abbr: "Admins")
@member_profiles.sample(2).each do |profile|
  assign!(profile[:user], admins, "Server Admin", Date.current - rand(100..600))
end

# Squad-leadership candidates: members working toward NCO rank
slt = Unit.find_by!(abbr: "SLT")
@member_profiles
  .select { |p| p[:user].rank.abbr == "PFC" && p[:career_end].nil? }
  .sample(8)
  .each { |p| assign!(p[:user], slt, "SLT Candidate", Date.current - rand(10..90)) }

# Cadets currently in basic training
Unit.active.training.where("abbr LIKE ?", "TP %").find_each do |tp|
  enlist_month = TRAINING_PLATOONS.find { |t| t[:unit] == tp }[:month]
  rand(4..8).times do
    enlist_date = [enlist_month - rand(3..10), Date.current - 3].min
    user = create_user!(rank_abbr: "Rec.", enlist_date:, game: tp.game)
    assign!(user, tp, "Recruit", [enlist_month, Date.current].min)
    @member_profiles.last[:cadet] = true
  end
end

# Recruits awaiting a training platoon
recruit_pool = Unit.find_by!(abbr: "Recruit Pool")
2.times do
  enlist_date = Date.current - rand(3..12)
  user = create_user!(rank_abbr: "Rec.", enlist_date:, game: "squad")
  assign!(user, recruit_pool, "Recruit", enlist_date + 1)
  @member_profiles.last[:cadet] = true
end

puts "   active roster: #{User.count} users"

# --- Historical members: the 3-year enlistment funnel ---------------------

1_100.times do
  enlist_date = Date.current - rand(45..(36 * 30))
  game = TRAINING_PLATOONS.select { |tp| tp[:month] == enlist_date.beginning_of_month }
    .map { |tp| tp[:game] }.sample || "squad"
  user = create_user!(rank_abbr: "Rec.", enlist_date:, game:)
  profile = @member_profiles.last

  status_roll = rand
  if status_roll < 0.21
    profile[:enlist_status] = :withdrawn
    next
  elsif status_roll < 0.31
    profile[:enlist_status] = :denied
    next
  end

  tp = training_platoon_for(enlist_date, game)
  if status_roll < 0.48 # went AWOL during basic training
    profile[:enlist_status] = :awol
    assign!(user, tp, "Recruit", enlist_date + 2, enlist_date + rand(5..20))
    next
  end

  # Accepted. ~30% wash out of BCT; the rest graduate into a squad and
  # churn out on the production curve (median ended assignment ~44 days,
  # long tail out to ~1.5 years), ending in a discharge.
  if rand < 0.3
    assign!(user, tp, "Recruit", enlist_date + 2, enlist_date + rand(10..27))
    profile[:graduated] = false
    next
  end

  assign!(user, tp, "Recruit", enlist_date + 2, enlist_date + BCT_DAYS)
  career_days = case rand
  when 0..0.4 then rand(14..60)
  when 0.4..0.7 then rand(60..180)
  when 0.7..0.9 then rand(180..540)
  else rand(540..1_200)
  end
  squad_start = enlist_date + BCT_DAYS
  career_end = [squad_start + career_days, Date.current - 7].min
  squad = active_squads.sample
  rank = (career_days > 700) ? "Cpl." : ((career_days > 240) ? "PFC" : "Pvt.")
  assign!(user, squad, squad_member_positions.sample, squad_start, career_end)
  plan_promotions!(user, rank, enlist_date, career_end)
  user.update!(rank: RANKS.fetch(rank))
  profile[:career_end] = career_end

  discharge_type = if career_days < 180
    (rand < 0.75) ? :general : ((rand < 0.97) ? :honorable : :dishonorable)
  else
    (rand < 0.7) ? :honorable : :general
  end
  Discharge.create!(user:, date: career_end, type: discharge_type,
    reason: (discharge_type == :honorable) ?
      "Discharged at own request after service in good standing." :
      Faker::Lorem.sentence(word_count: 8),
    was_reversed: false, forum_id: forum_for(career_end),
    topic_id: fake_topic_id.to_s)
end

Promotion.insert_all(@promotion_rows)
puts "   users: #{User.count}, assignments: #{Assignment.count}, promotions: #{@promotion_rows.size}"

# --- Enlistment papers for everyone ----------------------------------------

liaisons = Unit.find_by!(abbr: "LH").users.distinct.to_a
veteran_recruiters = @member_profiles
  .select { |p| p[:career_end].nil? && !p[:cadet] && p[:enlist_date] < 1.year.ago.to_date }
  .map { |p| p[:user] }
  .sample(30)
recruit_sources = ["", "", "Google", "YouTube", "Reddit", "A friend", "Steam forums"]

@member_profiles.each do |profile|
  user = profile[:user]
  date = profile[:enlist_date]
  recruiter_user = (rand < 0.5) ? veteran_recruiters.sample : nil
  tp = if profile[:enlist_status] == :accepted && user.assignments.any?
    user.assignments.joins(:unit).merge(Unit.training).first&.unit
  end

  enlistment = Enlistment.create!(
    user:, date:, status: profile[:enlist_status],
    unit: tp, liaison: liaisons.sample,
    age: rand(15..32).to_s,
    timezone: %i[est est est gmt gmt pst any_timezone].sample,
    game: profile[:game].to_s,
    ingame_name: Faker::Internet.username(specifier: 5..12),
    steam_name: (rand < 0.6) ? Faker::Internet.username(specifier: 5..12) : nil,
    steam_id: user.steam_id,
    email: user.email.first(60),
    discord_username: (rand < 0.7) ? Faker::Internet.username(specifier: 4..20) : nil,
    experience: Faker::Lorem.paragraph(sentence_count: 2),
    comments: (rand < 0.4) ? Faker::Lorem.sentence : "",
    recruiter: recruiter_user ? recruiter_user.short_name : recruit_sources.sample,
    recruiter_user:,
    forum_id: forum_for(date), topic_id: fake_topic_id
  )
  profile[:enlistment] = enlistment
end
puts "   enlistments: #{Enlistment.count}"

# A few pending enlistments to exercise the processing workflow
3.times do
  enlist_date = Date.current - rand(0..5)
  user = create_user!(rank_abbr: "Rec.", enlist_date:, game: "squad")
  profile = @member_profiles.pop # keep pending users out of the extras passes
  Enlistment.create!(
    user:, date: enlist_date, status: :pending,
    liaison: liaisons.sample, age: rand(15..32).to_s,
    timezone: :est, game: "squad",
    ingame_name: Faker::Internet.username(specifier: 5..12),
    steam_id: user.steam_id, email: user.email.first(60),
    discord_username: Faker::Internet.username(specifier: 4..20),
    experience: Faker::Lorem.paragraph(sentence_count: 2),
    comments: "", recruiter: recruit_sources.sample,
    forum_id: "Discourse", topic_id: fake_topic_id
  )
end

# --- Awards, qualifications and other per-member extras --------------------

award_pool = Award.where(active: true).to_a.shuffle
# Zipf-ish weights: a handful of awards account for most awardings
award_weights = award_pool.each_with_index.map { |_, i| 1.0 / (i + 1) }
award_weight_total = award_weights.sum

def weighted_award(pool, weights, total)
  roll = rand * total
  pool.each_with_index do |award, i|
    roll -= weights[i]
    return award if roll <= 0
  end
  pool.last
end

award_rows = []
qual_rows = []
standards_by_game = AITStandard.all.group_by(&:game)
instructors = Unit.find_by!(abbr: "Ord").users.distinct.to_a

@member_profiles.each do |profile|
  next unless profile[:graduated] && !profile[:cadet]
  user = profile[:user]
  service_start = profile[:enlist_date] + BCT_DAYS
  service_end = profile[:career_end] || Date.current
  service_days = (service_end - service_start).to_i
  next if service_days <= 0

  # Awardings: ~2 for BCT graduation, then steady accrual (active-member
  # median in production is ~19)
  count = 2 + [(service_days / 60.0 * rand(0.5..1.5)).round, 40].min
  count.times do
    date = service_start + rand(0..service_days)
    award_rows << {member_id: user.id, date:,
                   award_id: weighted_award(award_pool, award_weights, award_weight_total).id,
                   forum_id: forum_for(date), topic_id: fake_topic_id}
  end

  # AIT qualifications in the member's game (median ~38 for active members)
  standards = standards_by_game[profile[:game].to_s] || []
  qual_count = [3 + (service_days / 30.0 * rand(0.8..1.6)).round, standards.size, 60].min
  standards.sample(qual_count).each do |standard|
    qual_rows << {member_id: user.id, standard_id: standard.id,
                  date: service_start + rand(0..service_days),
                  author_member_id: instructors.sample&.id}
  end
end

UserAward.insert_all(award_rows)
qual_rows.each_slice(5_000) { |slice| AITQualification.insert_all(slice) }
puts "   awardings: #{award_rows.size}, qualifications: #{qual_rows.size}"

active_profiles = @member_profiles.select { |p| p[:career_end].nil? && !p[:cadet] }

# Extended LOAs (~200/year in production, mostly in the past)
active_profiles.sample(active_profiles.size / 6).each do |profile|
  rand(1..2).times do
    start_date = profile[:enlist_date] + BCT_DAYS + rand(30..600)
    next if start_date >= Date.current
    end_date = start_date + rand(7..45)
    ExtendedLOA.create!(user: profile[:user], start_date:, end_date:,
      return_date: (end_date < Date.current && rand < 0.8) ? end_date + rand(0..5) : nil,
      reason: Faker::Lorem.sentence(word_count: 6),
      availability: (rand < 0.5) ? "Reachable on Discord" : nil)
  end
end
# ...and a few currently on leave
active_profiles.sample(3).each do |profile|
  ExtendedLOA.create!(user: profile[:user],
    start_date: Date.current - rand(3..10), end_date: Date.current + rand(7..30),
    reason: Faker::Lorem.sentence(word_count: 6), availability: "Limited")
end

# Weapon passes: recruitment rewards and donor passes
finance_authors = Unit.find_by!(abbr: "Fin").users.distinct.to_a
Enlistment.accepted.where.not(recruiter_member_id: nil).limit(25).find_each do |enlistment|
  Pass.create!(user: enlistment.recruiter_user, recruit: enlistment.user,
    author: finance_authors.sample, type: :recruitment,
    start_date: enlistment.date, end_date: enlistment.date + 30,
    reason: "Pass for recruiting #{enlistment.user.last_name}")
end
active_profiles.sample(12).each do |profile|
  start_date = Date.current - rand(0..60)
  Pass.create!(user: profile[:user], author: finance_authors.sample,
    type: :recurring_donation, start_date:, end_date: start_date + 90,
    reason: "Soldier has made a recurring donation.")
end

# Admin notes on members (rare; various visibility levels)
note_authors = (Unit.find_by!(abbr: "MP").users.distinct.to_a + liaisons).uniq
note_accesses = ["Members Only", "Squad Level", "Platoon Level",
  "Company Level", "Battalion HQ", "Military Police", "Lighthouse"]
note_rows = @member_profiles.sample(60).map do |profile|
  date = Faker::Date.between(from: profile[:enlist_date], to: Date.current)
  {member_id: profile[:user].id, author_member_id: note_authors.sample.id,
   date_add: date, date_mod: date, access: note_accesses.sample,
   subject: Faker::Lorem.sentence(word_count: 4).delete_suffix("."),
   content: Faker::Lorem.paragraph(sentence_count: 3)}
end
Note.insert_all(note_rows)

# Demerits are rare (~10/year in production)
mp_authors = Unit.find_by!(abbr: "MP").users.distinct.to_a
@member_profiles.sample(12).each do |profile|
  date = Faker::Date.between(from: profile[:enlist_date], to: Date.current)
  Demerit.create!(user: profile[:user], author: mp_authors.sample,
    date:, reason: "AWOL from mandatory #{["squad drill", "platoon drill", "BCT session"].sample}",
    forum_id: forum_for(date), topic_id: fake_topic_id)
end

# Finance ledger: monthly hosting invoices out, donations in
36.downto(1) do |months_ago|
  month = months_ago.months.ago.to_date.beginning_of_month
  [["game_servers", 60], ["digital_ocean", 24], ["google", 12]].each do |vendor, amount|
    FinanceRecord.create!(date: month + 3, vendor:, amount_paid: amount,
      notes: "Monthly invoice")
  end
  rand(4..10).times do
    amount = [5, 10, 10, 15, 20, 25].sample
    FinanceRecord.create!(date: Faker::Date.between(from: month, to: month.end_of_month),
      vendor: :notapplicable, member_id: @member_profiles.sample[:user].id,
      amount_received: amount, fee: (0.3 + amount * 0.029).round(2),
      notes: "Donation")
  end
end

# Reserved surnames of notable former members
@member_profiles
  .select { |p| p[:career_end].present? }
  .sample(4)
  .each { |p| RestrictedName.create!(user: p[:user], name: p[:user].last_name) }

puts "   eloas: #{ExtendedLOA.count}, passes: #{Pass.count}, notes: #{Note.count}, " \
     "demerits: #{Demerit.count}, finances: #{FinanceRecord.count}"
