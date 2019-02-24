ActiveAdmin.register Permission do
  permit_params :unit_id, :access_level, :ability_id

  filter :unit
  filter :ability
  filter :access_level, :as => :select, :collection => Permission.access_levels

  index do
    selectable_column
    column :unit
    column :access_level
    column :ability
    actions
  end
end
