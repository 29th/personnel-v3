class ChangeMiddleNametoNullableOnEnlistments < ActiveRecord::Migration[7.1]
  def change
    change_column_null :enlistments, :middle_name, true
  end
end
