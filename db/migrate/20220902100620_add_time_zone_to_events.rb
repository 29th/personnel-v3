class AddTimeZoneToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :time_zone, :string, default: "Eastern Time (US & Canada)",
      comment: "Priority time zone for this event, usually based on host unit"
  end
end
