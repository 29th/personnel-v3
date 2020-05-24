ActiveAdmin.register Rank do
  actions :index, :show
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
