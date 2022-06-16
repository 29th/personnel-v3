class FixRankFilenameData < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      UPDATE ranks
        SET filename = 'cw2'
        WHERE filename = 'wo2'
        LIMIT 1;
    SQL

    execute <<~SQL
      UPDATE ranks
        SET filename = 'cw3'
        WHERE filename = 'wo3'
        LIMIT 1;
    SQL

    execute <<~SQL
      UPDATE ranks
        SET filename = 'cw4'
        WHERE filename = 'wo4'
        LIMIT 1;
    SQL

    execute <<~SQL
      UPDATE ranks
        SET filename = 'cw5'
        WHERE filename = 'wo5'
        LIMIT 1;
    SQL

    execute <<~SQL
      UPDATE ranks
        SET filename = CONCAT(filename, '.png')
        WHERE filename NOT LIKE '%.png';
    SQL

    execute <<~SQL
      DELETE FROM ranks
        WHERE name = 'Colonel'
        LIMIT 1;
    SQL
  end
end
