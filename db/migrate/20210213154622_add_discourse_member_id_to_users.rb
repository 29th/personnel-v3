class AddDiscourseMemberIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :discourse_forum_member_id, :integer
    add_index :members, :discourse_forum_member_id, unique: true
  end
end
