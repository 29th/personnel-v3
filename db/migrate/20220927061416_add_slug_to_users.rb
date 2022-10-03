class AddSlugToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :slug, :string
    add_index :members, :slug, unique: true
  end
end
