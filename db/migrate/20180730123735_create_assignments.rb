class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
      t.references :unit, foreign_key: true
      t.references :user, foreign_key: true
      t.references :position, foreign_key: true

      t.timestamps
    end
  end
end
