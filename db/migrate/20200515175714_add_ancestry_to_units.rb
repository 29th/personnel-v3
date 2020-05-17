class AddAncestryToUnits < ActiveRecord::Migration[6.0]
  def change
    add_column :units, :ancestry, :string
    add_index :units, :ancestry

    sql = <<~EOF
      UPDATE units
      SET ancestry = NULLIF(TRIM(BOTH '/' FROM path), '')
    EOF
    Unit.connection.execute(sql)
  end
end
