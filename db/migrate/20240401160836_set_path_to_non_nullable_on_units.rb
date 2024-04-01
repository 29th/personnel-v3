class SetPathToNonNullableOnUnits < ActiveRecord::Migration[7.1]
  def change
    change_column_null :units, :path, false
  end
end
