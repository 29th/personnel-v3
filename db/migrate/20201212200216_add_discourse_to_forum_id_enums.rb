class AddDiscourseToForumIdEnums < ActiveRecord::Migration[6.0]
  def change
    tables = [
      :awardings,
      :demerits,
      :discharges,
      :eloas,
      :enlistments,
      :finances,
      :promotions
    ]

    tables.each do |table|
      change_column table, :forum_id, "enum('PHPBB','SMF','Vanilla','Discourse')"
    end
  end
end
