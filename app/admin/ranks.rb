ActiveAdmin.register Rank do
  actions :index, :show, :edit, :update, :new, :create
  permit_params :order, :abbr, :name, :grade, :filename, :description

  index do
    selectable_column
    column :order
    column :abbr
    column :name
    column :grade
    column :filename do |record|
      image_tag "ranks/60x60/#{record.filename}"
    end
    column :description
    actions
  end
end
