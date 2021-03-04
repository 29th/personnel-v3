class AddLogoDataToUnits < ActiveRecord::Migration[6.0]
  def change
    add_column :units, :logo_data, :text
  end
end
