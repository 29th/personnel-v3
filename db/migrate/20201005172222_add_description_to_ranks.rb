class AddDescriptionToRanks < ActiveRecord::Migration[6.0]
  def change
    add_column :ranks, :description, :text
  end
end
