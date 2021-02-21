class AddImageDataColumnsToAwards < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :display_image_data, :text
    add_column :awards, :mini_image_data, :text
  end
end
