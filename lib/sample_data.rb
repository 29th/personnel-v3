class SampleData
  include FactoryBot::Syntax::Methods

  def positions
    seeds = {
      platoon_leader: ["Platoon Leader", :leader],
      squad_leader: ["Squad Leader", :leader],
      asst_squad_leader: ["Asst. Squad Leader", :elevated],
      rifleman: ["Rifleman", :member]
    }
    seeds.each do |key, (name, access_level)|
      create(:position, access_level: access_level, name: name)
    end
  end
end
