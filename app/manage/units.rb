ActiveAdmin.register Unit do
  actions :index, :show, :edit, :update, :new, :create
  permit_params :name, :abbr, :order, :game, :timezone, :parent_id,
    :classification, :active, :steam_group_abbr, :slogan,
    :nickname, :logo, :remove_logo

  filter :abbr
  filter :name
  filter :game, as: :select, collection: -> { Unit.games }
  filter :timezone, as: :select, collection: -> { Unit.timezones }
  filter :classification, as: :select, collection: -> { Unit.classifications }

  scope :active, default: true
  scope :all, default: true

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  searchable_select_options(
    name: :active_training_platoons,
    scope: -> {
      Unit.training_platoons
        .active
        .with_event_range
        .order(:ancestry, :order, :name)
    },
    text_attribute: :abbr,
    display_text: ->(record) {
      game = Unit.games[record.game]
      timezone = Unit.timezones[record.timezone]
      "#{record.abbr} (#{game}) (#{timezone}) - #{record.event_range}"
    }
  )

  index do
    column :abbr
    column :name
    column :ancestors
    column :game
    column :classification
    column :active
    actions defaults: false do |unit|
      item "View", manage_unit_path(unit)
    end
  end

  sidebar "Related records", only: [:show, :edit] do
    ul do
      # See https://github.com/activeadmin/activeadmin/issues/221#issuecomment-502802948
      li link_to "Assignments", [:manage, :assignments, q: {unit_id_eq: resource.id}] if authorized?(:index, Assignment)
      li link_to "Unit Forum Roles", manage_unit_unit_forum_roles_path(resource) if authorized?(:index, UnitForumRole)
      li link_to "Users", manage_unit_users_path(resource) if authorized?(:index, User)
    end
  end

  show do
    attributes_table do
      row :id
      row :name
      row :abbr
      row :ancestors
      row :order
      row :classification
      row :game
      row :timezone
      row :active
      row :nickname
      row :slogan
      row :steam_group_abbr
      row :logo do |unit|
        image_tag unit.logo_url if unit.logo.present?
      end
    end
  end

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :abbr
      f.input :parent_id, as: :select, collection: Unit.for_dropdown(f.object&.parent)
      f.input :order, as: :number
      f.input :classification, as: :select, collection: Unit.classifications.map(&:reverse), include_blank: false
      f.input :game, as: :select, collection: Unit.games.map(&:reverse)
      f.input :timezone, as: :select, collection: Unit.timezones.map(&:reverse)
      f.input :active
      f.input :nickname
      f.input :slogan
      f.input :steam_group_abbr
      f.input :logo, as: :hidden, input_html: {value: object&.cached_logo_data}
      f.input :logo, as: :file
      f.input :remove_logo, as: :boolean if object&.logo.present?
    end
    f.actions
  end

  after_update do |unit|
    unit.end_assignments if unit.saved_change_to_active? && unit.active == false
  end
end
