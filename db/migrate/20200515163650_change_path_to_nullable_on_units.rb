class ChangePathToNullableOnUnits < ActiveRecord::Migration[6.0]
  def change
    change_column_null :units, :path, from: false, to: true
  end
end
