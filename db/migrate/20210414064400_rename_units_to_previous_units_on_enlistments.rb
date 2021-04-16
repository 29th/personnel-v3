class RenameUnitsToPreviousUnitsOnEnlistments < ActiveRecord::Migration[6.0]
  def change
    rename_column :enlistments, :units, :previous_units
  end
end
