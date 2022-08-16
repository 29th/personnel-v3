class AddTimeZoneToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :time_zone, :string, default: "UTC"
  end
end
