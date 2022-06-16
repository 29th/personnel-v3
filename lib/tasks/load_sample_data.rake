require "factory_bot"
require "sample_data"

namespace :dev do
  desc "Load sample data for development"
  task load_sample_data: ["db:truncate_all"] do
    include FactoryBot::Syntax::Methods

    positions = {}
    positions["platoon_leader"] = create(:position, access_level: :leader, name: "Platoon Leader")
    positions["squad_leader"] = create(:position, access_level: :leader, name: "Squad Leader")
    positions["asst_squad_leader"] = create(:position, access_level: :elevated, name: "Asst. Squad Leader")
    positions["rifleman"] = create(:position, access_level: :member, name: "Rifleman")

    ranks = {}
    ranks["2lt"] = create(:rank, abbr: "2Lt.", name: "Second Lieutenant")
    ranks["sgt"] = create(:rank, abbr: "Sgt.", name: "Sergeant")
    ranks["cpl"] = create(:rank, abbr: "Cpl.", name: "Corporal")
    ranks["pvt"] = create(:rank, abbr: "Pvt.", name: "Private")

    # def create_squad(abbr:, name:, parent:, size: 8)
    create_squad = ->(abbr:, name:, parent:, size: 8) do
      unit = create(:unit, abbr: abbr, name: name, parent: parent)

      size.times do |index|
        if index == 0
          rank = ranks["sgt"]
          position = positions["squad_leader"]
        elsif index == 1 && size >= 5
          rank = ranks["cpl"]
          position = positions["asst_squad_leader"]
        else
          rank = ranks["pvt"]
          position = positions["rifleman"]
        end

        user = create(:user, rank: rank)
        create(:assignment, user: user, unit: unit, position: position)
      end

      unit
    end

    units = {}
    units["cp1"] = create(:unit, abbr: "CP1 HQ",
      name: "Charlie Company, First Platoon")
    units["cp1s1"] = create_squad.call(abbr: "CP1S1",
      name: "Charlie Company, First Platoon, First Squad",
      parent: units["cp1"])
    units["cp1s2"] = create_squad.call(abbr: "CP1S2",
      name: "Charlie Company, First Platoon, Second Squad",
      parent: units["cp1"])

    users = {}
    users["cp1_pl"] = create(:user, rank: ranks["2lt"])
    create(:assignment, user: users["cp1_pl"], unit: units["cp1"], position: positions["platoon_leader"])
  end

  task load_sample_data2: ["db:truncate_all"] do
    puts "Hello, world"
    sample_data = SampleData.new
    sample_data.positions
    puts "Done"
  end
end
