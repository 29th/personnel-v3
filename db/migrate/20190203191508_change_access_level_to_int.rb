# Rails interprets MySQL tinyint(1) columns as booleans. We actually want ints.
class ChangeAccessLevelToInt < ActiveRecord::Migration[5.2]
  def change
    tables = [:assignments, :positions, :unit_permissions, :unit_roles]
    tables.each do |table|
      change_table table do |t|
        t.change :access_level, :integer, limit: 1
      end
    end
  end
end
