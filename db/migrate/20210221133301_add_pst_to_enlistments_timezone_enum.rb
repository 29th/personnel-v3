class AddPstToEnlistmentsTimezoneEnum < ActiveRecord::Migration[6.0]
  def change
    change_column :enlistments, :timezone, "enum('EST','GMT','Either','Neither','PST','Any','None')"

    execute <<~SQL
      UPDATE enlistments
      SET timezone = 'Any'
      WHERE timezone = 'Either';
    SQL

    execute <<~SQL
      UPDATE enlistments
      SET timezone = 'None'
      WHERE timezone = 'Neither';
    SQL

    change_column :enlistments, :timezone, "enum('EST','GMT','PST','Any','None')"
  end
end
