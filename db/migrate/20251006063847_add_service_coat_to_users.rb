class AddServiceCoatToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :service_coat_data, :text
  end
end
