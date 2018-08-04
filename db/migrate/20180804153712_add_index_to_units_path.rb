class AddIndexToUnitsPath < ActiveRecord::Migration[5.2]
  def change
    add_index :units, :path, using: :gist
  end
end
