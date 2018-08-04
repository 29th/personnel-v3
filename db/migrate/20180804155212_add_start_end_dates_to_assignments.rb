class AddStartEndDatesToAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :started_at, :date, null: false, default: -> { 'current_date' }
    add_index :assignments, :started_at

    add_column :assignments, :ended_at, :date
    add_index :assignments, :ended_at
  end
end
