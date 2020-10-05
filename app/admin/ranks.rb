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

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      input :name
      input :abbr
      input :grade
      input :order
      input :filename
      input :description
    end
    f.actions
  end
end
