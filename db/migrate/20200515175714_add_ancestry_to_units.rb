class AddAncestryToUnits < ActiveRecord::Migration[6.0]
  def change
    add_column :units, :ancestry, :string
    add_index :units, :ancestry
  end
end
