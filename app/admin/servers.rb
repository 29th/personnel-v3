ActiveAdmin.register Server do
  actions :index, :show, :edit, :update, :new, :create
  permit_params :name, :abbr, :address, :port, :game, :active, :battle_metrics_id

  scope :all, default: true
  scope :active

  filter :game, as: :select, collection: -> { Server.games.map(&:reverse) }

  index do
    selectable_column
    column :game
    column :name
    column :abbr
    column :address
    column :port
    column :active
    column :battle_metrics_id
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      input :game, collection: Server.games.map(&:reverse)
      input :name
      input :abbr
      input :address
      input :port
      input :active
      input :battle_metrics_id
    end
    f.actions
  end
end
