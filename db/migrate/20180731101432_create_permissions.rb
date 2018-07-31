class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.references :unit, foreign_key: true
      t.integer :access_level
      t.string :ability

      t.timestamps
    end
  end
end
