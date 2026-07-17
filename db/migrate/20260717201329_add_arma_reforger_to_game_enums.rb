class AddArmaReforgerToGameEnums < ActiveRecord::Migration[8.0]
  # Append 'Arma Reforger' to each game enum. 'Arma 3' is intentionally kept so
  # historic records remain viewable and editable. Appending to the end of a
  # MySQL enum is an instant metadata-only change (inserting mid-list would
  # force a full table rebuild).
  def up
    change_column :enlistments, :game, "enum('DH','RS','Arma 3','RS2','Squad','Arma Reforger')", default: "DH"
    change_column :servers, :game, "enum('DH','Arma 3','RS','RS2','Squad','Arma Reforger')", default: "DH", null: false
    change_column :units, :game, "enum('DH','RS','Arma 3','RS2','Squad','Arma Reforger')"
    change_column :standards, :game, "enum('DH','RS','Arma 3','RS2','Squad','Arma Reforger')", default: "DH", null: false
    change_column :awards, :game, "enum('N/A','DH','DOD','Arma 3','RS','RS2','Squad','Arma Reforger')", null: false
  end

  def down
    change_column :enlistments, :game, "enum('DH','RS','Arma 3','RS2','Squad')", default: "DH"
    change_column :servers, :game, "enum('DH','Arma 3','RS','RS2','Squad')", default: "DH", null: false
    change_column :units, :game, "enum('DH','RS','Arma 3','RS2','Squad')"
    change_column :standards, :game, "enum('DH','RS','Arma 3','RS2','Squad')", default: "DH", null: false
    change_column :awards, :game, "enum('N/A','DH','DOD','Arma 3','RS','RS2','Squad')", null: false
  end
end
