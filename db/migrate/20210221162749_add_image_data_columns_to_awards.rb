class AddImageDataColumnsToAwards < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :presentation_image_data, :text
    add_column :awards, :ribbon_image_data, :text
  end
end
