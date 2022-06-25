class ChangeColumnsToNullableOnEvents < ActiveRecord::Migration[6.0]
  def change
    change_column_null :events, :title, from: false, to: true
    change_column_null :events, :server, from: false, to: true
    change_column_null :events, :report, from: false, to: true
  end
end
