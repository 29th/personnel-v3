class CreateUnits < ActiveRecord::Migration[5.2]
  def change
    enable_extension "ltree"

    create_table :units do |t|
      t.string :name
      t.string :abbr
      t.ltree :parent_path

      t.timestamps
    end
  end
end
