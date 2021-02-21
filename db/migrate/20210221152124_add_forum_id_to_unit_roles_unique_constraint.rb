class AddForumIdToUnitRolesUniqueConstraint < ActiveRecord::Migration[6.0]
  def change
    add_index :unit_roles, %i[unit_id role_id forum_id], unique: true
    remove_index :unit_roles, name: :unit_id
  end
end
