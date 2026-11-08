class AddHqReviewAndFailToEnlistmentsStatusEnum < ActiveRecord::Migration[8.0]
  # Append 'HQ Review' and 'Fail' to the end of the status enum. Appending is
  # an instant metadata-only change in MySQL; inserting mid-list forces a
  # full table rebuild.
  def up
    change_column :enlistments, :status,
      "enum('Pending','Accepted','Denied','Withdrawn','AWOL','HQ Review','Fail')",
      default: "Pending", null: false
  end

  def down
    change_column :enlistments, :status,
      "enum('Pending','Accepted','Denied','Withdrawn','AWOL')",
      default: "Pending", null: false
  end
end
