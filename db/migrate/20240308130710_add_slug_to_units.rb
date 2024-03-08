class AddSlugToUnits < ActiveRecord::Migration[7.1]
  def change
    add_column :units, :slug, :string
    add_index :units, :slug, unique: true
  end
end
