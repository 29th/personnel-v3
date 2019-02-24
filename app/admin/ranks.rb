ActiveAdmin.register Rank do
  permit_params :order, :abbr, :name, :grade, :filename

  index do
    selectable_column
    column :order
    column :abbr
    column :name
    column :grade
    column :filename
    actions
  end
end
