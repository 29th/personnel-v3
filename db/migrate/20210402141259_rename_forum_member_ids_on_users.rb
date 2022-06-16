class RenameForumMemberIdsOnUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column :members, :forum_member_id, :vanilla_forum_member_id
    rename_column :members, :discourse_forum_member_id, :forum_member_id
  end
end
