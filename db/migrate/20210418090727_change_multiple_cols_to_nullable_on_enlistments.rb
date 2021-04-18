class ChangeMultipleColsToNullableOnEnlistments < ActiveRecord::Migration[6.0]
  def change
    columns = [
      :topic_id,
      :steam_name,
      :email,
      :body
    ]

    columns.each do |column|
      change_column_null :enlistments, column, true
    end
  end
end
