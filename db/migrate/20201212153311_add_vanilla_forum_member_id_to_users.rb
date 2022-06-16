class AddVanillaForumMemberIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :vanilla_forum_member_id, :integer
  end
end
