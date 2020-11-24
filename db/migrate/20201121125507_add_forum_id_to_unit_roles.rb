class AddForumIdToUnitRoles < ActiveRecord::Migration[6.0]
  def up
    add_column :unit_roles, :forum_id,
               "enum('Vanilla','Discourse')",
               null: false

    execute <<~SQL
      UPDATE unit_roles
        SET forum_id = 'Vanilla';
    SQL
  end

  def down
    remove_column :unit_roles, :forum_id
  end
end
