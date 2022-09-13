class AddStartsAtToEvents < ActiveRecord::Migration[6.1]
  def up
    add_column :events, :starts_at, :datetime, comment: "Start date/time in UTC"

    execute <<~SQL
      UPDATE events
      SET starts_at = CONVERT_TZ(datetime, 'US/Eastern', 'UTC');
    SQL
  end

  def down
    remove_column :events, :starts_at
  end
end
