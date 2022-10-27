class AddStartsAtIndexToEvents < ActiveRecord::Migration[7.0]
  def change
    add_index :events, :starts_at
  end
end
