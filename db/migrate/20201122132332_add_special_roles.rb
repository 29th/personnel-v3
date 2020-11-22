class AddSpecialRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :special_roles do |t|
      t.string :special_attribute, null: false
      t.integer :role_id, null: false
      t.column :forum_id, "enum('Vanilla','Discourse')",
                          null: false
    end
  end
end
