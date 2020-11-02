class AddDisplayFilenameAndMiniFilenameToAwards < ActiveRecord::Migration[6.0]
  def up
    add_column :awards, :display_filename, :string
    add_column :awards, :mini_filename, :string

    execute <<~SQL
      UPDATE awards
        SET display_filename = SUBSTRING_INDEX(bar, '/', -1),
            mini_filename = SUBSTRING_INDEX(bar, '/', -1);
    SQL
  end

  def down
    remove_column :awards, :display_filename
    remove_column :awards, :mini_filename
  end
end
