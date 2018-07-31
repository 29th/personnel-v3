class CreateRanks < ActiveRecord::Migration[5.2]
  def change
    create_table :ranks do |t|
      t.string :abbr
      t.string :name

      t.timestamps
    end

    add_reference :users, :rank, foreign_key: true
  end
end
