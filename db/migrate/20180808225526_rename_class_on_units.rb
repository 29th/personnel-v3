class RenameClassOnUnits < ActiveRecord::Migration[5.2]
  def change
    # `class` is a reserved word in ruby
    rename_column :units, :class, :classification
  end
end
