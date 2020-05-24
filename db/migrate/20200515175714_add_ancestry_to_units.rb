class AddAncestryToUnits < ActiveRecord::Migration[6.0]
  def change
    add_column :units, :ancestry, :string
    add_index :units, :ancestry

    sql = <<~SQL
      UPDATE units
      SET ancestry = NULLIF(TRIM('/' FROM TRIM(' ' FROM path)), '')
    SQL
    Unit.connection.execute(sql)
  end
end
