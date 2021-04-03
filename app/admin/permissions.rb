ActiveAdmin.register Permission do
  includes :unit, :ability
  permit_params :unit_id, :access_level, :ability_id

  filter :unit, collection: -> { Unit.for_dropdown }
  filter :ability
  filter :access_level, as: :select, collection: Permission.access_levels

  config.create_another = true

  index do
    selectable_column
    column :unit
    column :access_level
    column :ability
    column :ability_name do |permission|
      permission.ability.name if permission.ability.present?
    end
    actions
  end

  show do
    attributes_table do
      row :unit
      row :access_level
      row :ability
      row :ability_name do |permission|
        permission.ability.name if permission.ability.present?
      end
    end
  end
end
