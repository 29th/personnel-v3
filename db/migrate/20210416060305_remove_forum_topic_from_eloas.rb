class RemoveForumTopicFromEloas < ActiveRecord::Migration[6.0]
  def change
    remove_column :eloas, :forum_id, "enum('PHPBB','SMF','Vanilla','Discourse')"
    remove_column :eloas, :topic_id, :integer, limit: 3, default: 0, null: false
  end
end
