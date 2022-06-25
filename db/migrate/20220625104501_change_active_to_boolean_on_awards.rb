class ChangeActiveToBooleanOnAwards < ActiveRecord::Migration[6.0]
  def up
    change_column :awards, :active, :boolean
  end

  def down
    change_column :awards, :active, :integer, limit: 1, default: 1, unsigned: true
  end
end
