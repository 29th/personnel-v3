class SetEnlistmentsPreviousUnitsDefaultValueToEmptyArray < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      UPDATE enlistments
        SET previous_units = (JSON_ARRAY())
      WHERE previous_units IS NULL
         OR previous_units = ''
    SQL

    # JSON column defaults must be an 'expression' (wrapped in parens), which rails
    # migration methods don't seem to do, so we're using raw SQL here.
    execute <<~SQL
      ALTER TABLE enlistments
        MODIFY COLUMN previous_units JSON NOT NULL DEFAULT (JSON_ARRAY())
    SQL
  end

  def down
    change_column :enlistments, :previous_units, :json, default: nil, null: true

    execute <<~SQL
      UPDATE enlistments
        SET previous_units = NULL
      WHERE previous_units = (JSON_ARRAY())
    SQL
  end
end
