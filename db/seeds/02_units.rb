# The unit tree mirrors the real (public) active org chart: a regiment with
# two battalions of game-specific companies, an HQ staff branch, and training
# platoons under Lighthouse Corps. Historical (inactive) units are included
# so discharged members' old assignments have realistic targets.

ORDINALS = %w[First Second Third Fourth]
TP_GAME_ABBR = {dh: "DH", rs: "RS", arma3: "A3", rs2: "RS2", squad: "SQ"}
TP_GAME_NAME = {dh: "Darkest Hour", rs: "Rising Storm", arma3: "Arma 3",
                rs2: "Rising Storm 2", squad: "Squad"}

# Registry of training platoons by month, used by 04_members.rb to assign
# each member's basic training to a platoon matching their enlistment date
TRAINING_PLATOONS = []

@unit_order = 0

def seed_unit!(name:, abbr:, classification:, parent: nil, **attrs)
  unit = Unit.new(name:, abbr:, classification:, parent:,
    order: (@unit_order += 1), **attrs)
  unit[:class] = classification.to_s.capitalize # legacy v2 column
  unit.path = "/" if parent.nil? # legacy column; a callback sets it for non-roots
  unit.save!
  unit
end

def seed_company!(parent:, name:, letter:, game:, platoons:, active: true)
  company = seed_unit!(name: "#{name} Company", abbr: "#{name} Co. HQ",
    classification: :combat, parent:, game:, active:,
    slogan: Faker::Company.catch_phrase, nickname: name)
  platoons.each_with_index do |squad_count, pi|
    platoon = seed_unit!(name: "#{name} Company, #{ORDINALS[pi]} Platoon",
      abbr: "#{letter}P#{pi + 1} HQ", classification: :combat,
      parent: company, game:, active:)
    squad_count.times do |si|
      # last squad of each platoon drills on a European schedule
      timezone = (si == squad_count - 1) ? :gmt : :est
      seed_unit!(name: "#{name} Company, #{ORDINALS[pi]} Platoon, #{ORDINALS[si]} Squad",
        abbr: "#{letter}P#{pi + 1}S#{si + 1}", classification: :combat,
        parent: platoon, game:, active:, timezone:)
    end
  end
  company
end

def seed_training_platoon!(parent:, month:, game:, active:)
  unit = seed_unit!(
    name: "#{month.strftime("%B %Y")} Training Platoon #{TP_GAME_NAME[game]}",
    abbr: "TP #{month.strftime("%y%m")} #{TP_GAME_ABBR[game]}",
    classification: :training, parent:, game:, active:
  )
  TRAINING_PLATOONS << {unit:, month:, game:}
end

regiment = seed_unit!(name: "116th Infantry Regiment", abbr: "Regt. HQ",
  classification: :combat, slogan: "Ever Forward")

bn1 = seed_unit!(name: "First Battalion", abbr: "1st Bn. HQ",
  classification: :combat, parent: regiment)
seed_company!(parent: bn1, name: "Charlie", letter: "C", game: :arma3, platoons: [2, 2])
seed_company!(parent: bn1, name: "Dog", letter: "D", game: :rs2, platoons: [3, 4])

bn2 = seed_unit!(name: "Second Battalion", abbr: "2nd Bn. HQ",
  classification: :combat, parent: regiment)
seed_company!(parent: bn2, name: "Easy", letter: "E", game: :squad, platoons: [3, 3, 3])
seed_company!(parent: bn2, name: "Fox", letter: "F", game: :squad, platoons: [3, 3])

# Disbanded companies from earlier games; homes for old ended assignments
seed_company!(parent: bn1, name: "Able", letter: "A", game: :dh, platoons: [2, 2], active: false)
seed_company!(parent: bn1, name: "Baker", letter: "B", game: :rs, platoons: [2], active: false)

staff = seed_unit!(name: "Headquarters Staff", abbr: "Staff",
  classification: :staff, parent: regiment)
lighthouse = nil
{
  "S-1 Personnel" => ["Adjutant Corps Adj", "Finance Corps Fin", "Quartermaster Corps Quart"],
  "S-2 Intelligence" => ["Military Police Corps MP"],
  "S-3 Operations" => ["Civil Affairs Corps Civ", "Lighthouse Corps LH", "Operations Corps Oper", "Signal Corps Sig"],
  "S-4 Logistics" => ["Engineer Corps Eng", "Medical Corps Med", "Ordnance Corps Ord"]
}.each do |office_name, corps|
  office = seed_unit!(name: office_name, abbr: office_name.split(" ").first,
    classification: :staff, parent: staff)
  corps.each do |corps_entry|
    *name_words, abbr = corps_entry.split(" ")
    corps_unit = seed_unit!(name: name_words.join(" "), abbr:,
      classification: :staff, parent: office)
    lighthouse = corps_unit if abbr == "LH"
  end
end

seed_unit!(name: "Recruit Pool (Awaiting BCT Assignment)", abbr: "Recruit Pool",
  classification: :training, parent: lighthouse)
# Reserved stub unit; Unit.training_platoons excludes it by name
seed_unit!(name: "Training Platoons", abbr: "TPs",
  classification: :training, parent: lighthouse)

# Monthly training platoons covering the last 3 years (two games per month,
# rotating), matching the ~2-3 platoons/month production cadence. Only the
# most recent month's platoons are still active.
game_rotation = [%i[squad rs2], %i[squad arma3], %i[rs2 arma3]]
35.downto(0) do |months_ago|
  month = months_ago.months.ago.to_date.beginning_of_month
  game_rotation[month.month % 3].each do |game|
    seed_training_platoon!(parent: lighthouse, month:, game:,
      active: months_ago <= 1)
  end
end

# Sparser, older platoons so long-tenured veterans have a basic training
# unit from their era
(12..32).each do |quarters_ago|
  month = (quarters_ago * 3).months.ago.to_date.beginning_of_month
  game = (quarters_ago > 24) ? :dh : ((quarters_ago > 18) ? :rs : :rs2)
  seed_training_platoon!(parent: lighthouse, month:, game:, active: false)
end

seed_unit!(name: "Reserve Platoon", abbr: "Rsrv S1",
  classification: :combat, parent: regiment)

seed_unit!(name: "Squad Leadership Training", abbr: "SLT", classification: :staff)
seed_unit!(name: "Temporary Admins", abbr: "Admins", classification: :staff)

puts "   units: #{Unit.count} (#{Unit.active.count} active)"
