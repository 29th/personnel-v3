ActiveAdmin.register Position do
  permit_params :name, :active, :order, :description, :access_level, :AIT

  filter :name
  filter :access_level, as: :select
  filter :AIT, as: :select, collection: Position.AITs.map(&:reverse)

  index do
    selectable_column
    column :name
    column :access_level
    column :AIT
    column :order
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :name
      f.input :active
      f.input :description
      f.input :order
      f.input :access_level
      f.input :AIT, as: :select, collection: Position.AITs.map(&:reverse)
    end
    f.actions
  end
end
