ActiveAdmin.register Permission do
  includes :unit, :ability
  actions :index, :show
  permit_params :unit_id, :access_level, :ability_id

  filter :unit, collection: -> { Unit.active.order(:ancestry, :name) }
  filter :ability
  filter :access_level, as: :select, collection: Permission.access_levels

  index do
    selectable_column
    column :unit
    column :access_level
    column :ability
    actions
  end
end
