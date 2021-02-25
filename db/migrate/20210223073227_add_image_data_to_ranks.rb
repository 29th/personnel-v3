class AddImageDataToRanks < ActiveRecord::Migration[6.0]
  def change
    add_column :ranks, :image_data, :text
  end
end
