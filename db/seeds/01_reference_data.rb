# Real (non-personal) reference data extracted from production: the rank
# ladder, position catalogue, authorization abilities, awards, countries,
# AIT standards and game servers. Server addresses/ports are faked.

{
  Rank => "ranks.yml",
  Position => "positions.yml",
  Ability => "abilities.yml",
  Award => "awards.yml",
  Country => "countries.yml",
  Server => "servers.yml"
}.each do |model, file|
  rows = YAML.load_file(Rails.root.join("db/seeds/data", file))
  model.insert_all(rows)
  puts "   #{model.table_name}: #{rows.size}"
end

# The EIB and SLT standards predate the game column and store a legacy empty
# enum value, which AITStandard's enum would cast to NULL. Insert through a
# cast-free stub model with strict mode off — the same way a production dump
# import replays them.
standards_stub = Class.new(ApplicationRecord) { self.table_name = "standards" }
rows = YAML.load_file(Rails.root.join("db/seeds/data/ait_standards.yml"))
standards_stub.connection.execute("SET SESSION sql_mode = ''")
standards_stub.insert_all(rows)
standards_stub.connection.execute("SET SESSION sql_mode = DEFAULT")
puts "   standards: #{rows.size}"
