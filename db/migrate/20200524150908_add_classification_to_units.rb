class AddClassificationToUnits < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      ALTER TABLE units
      ADD classification enum('Combat', 'Staff', 'Training')
        DEFAULT 'Training'
        NOT NULL;
    SQL

    execute <<~SQL
      UPDATE units
      SET classification = class;
    SQL
  end

  def down
    remove_column :units, :classification
  end
end
