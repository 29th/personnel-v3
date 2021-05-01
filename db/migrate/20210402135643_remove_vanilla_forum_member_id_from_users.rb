class RemoveVanillaForumMemberIdFromUsers < ActiveRecord::Migration[6.0]
  def change
    # shouldn't have added this in the first place; renaming is better
    remove_column :members, :vanilla_forum_member_id, :integer
  end
end
