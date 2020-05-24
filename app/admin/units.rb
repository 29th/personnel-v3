ActiveAdmin.register Unit do
  actions :index, :show
  permit_params :name, :abbr, :ancestry, :order, :game, :timezone,
    :classification, :active, :steam_group_abbr, :slogan, :nickname, :logo

  form do |f|
    f.semantic_errors
    inputs do
      f.input :abbr
      f.input :name
      f.input :ancestry
      f.input :order, :as => :number
      f.input :game, :as => :select, :collection => Unit::GAME_OPTS
      f.input :timezone, :as => :select, :collection => Unit::TIMEZONE_OPTS
      f.input :classification, :as => :select, :collection => Unit::CLASSIFICATION_OPTS, :include_blank => false
      f.input :active
      f.input :steam_group_abbr
      f.input :slogan
      f.input :nickname
      f.input :logo
    end
    f.actions
  end

  filter :abbr
  filter :name
  filter :game, as: :select, collection: Unit.games
  filter :timezone, as: :select, collection: Unit.timezones
  filter :classification, as: :select, collection: Unit.classifications

  scope :active, default: true
  scope :all, default: true

  index do
    selectable_column
    column :abbr
    column :name
    column :ancestry
    column :game
    column :classification
    column :active
    actions
  end
end
