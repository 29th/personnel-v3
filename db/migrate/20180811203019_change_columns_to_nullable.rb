class ChangeColumnsToNullable < ActiveRecord::Migration[5.2]
  def change
    table_columns = {
      units: [
        :old_path,
        :timezone,
        :steam_group_abbr,
        :slogan,
        :logo,
        :nickname,
        :aar_template
      ],
      members: [
        :status,
        :steam_id,
        :email,
        :forum_member_id,
        :middle_name
      ],
      assignments: [
        :position,
        :access_level
      ],
      abilities: [
        :name,
        :description
      ],
      ranks: [
        :filename
      ],
      positions: [
        :description
      ]
    }
    table_columns.each do |table, columns|
      columns.each do |column|
        change_column_null table, column, true
      end
    end
  end
end
