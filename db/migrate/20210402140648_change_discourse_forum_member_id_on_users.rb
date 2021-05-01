class ChangeDiscourseForumMemberIdOnUsers < ActiveRecord::Migration[6.0]
  def up
    change_column :members, :discourse_forum_member_id, :integer, unsigned: true, limit: 3
  end

  def down
    change_column :members, :discourse_forum_member_id, :integer
  end
end
