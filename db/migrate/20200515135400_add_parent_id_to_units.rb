class AddParentIdToUnits < ActiveRecord::Migration[6.0]
  def change
    add_reference :units, :parent, type: :mediumint, unsigned: true,
                  foreign_key: { to_table: :units }

    sql = <<~EOF
      UPDATE units
      SET parent_id = NULLIF(
        TRIM(TRAILING '/' FROM SUBSTRING_INDEX(path, '/', -2)), 
        ''
      )
    EOF
    Unit.connection.execute(sql)
  end
end
