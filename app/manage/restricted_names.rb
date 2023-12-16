ActiveAdmin.register RestrictedName do
  includes user: :rank

  permit_params :name, :member_id

  config.filters = false
  config.sort_order = "name_asc"

  index do
    column :name
    column :user
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      input :name
      input :user, as: :searchable_select, ajax: true
    end
    f.actions
  end
end
