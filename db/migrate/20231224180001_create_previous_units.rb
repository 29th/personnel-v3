class CreatePreviousUnits < ActiveRecord::Migration[7.1]
  def change
    create_table :previous_units do |t|
      t.references :enlistment, null: false, foreign_key: true, type: :integer, limit: 3, unsigned: true
      t.string :unit, limit: 64
      t.string :game, limit: 64
      t.string :name, limit: 64
      t.string :rank, limit: 64
      t.string :reason, limit: 256
    end
  end
end
