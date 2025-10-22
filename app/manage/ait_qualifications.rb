ActiveAdmin.register AITQualification do
  belongs_to :user, optional: true, finder: :find_by_slug
  actions :index, :show, :new, :create, :destroy
  includes user: :rank, author: :rank
  includes :ait_standard
  permit_params :member_id, :standard_id, :author_member_id, :date
  menu parent: "AIT"

  filter :user, as: :searchable_select, ajax: true
  filter :date
  filter :ait_standard_game_eq, label: "Game", as: :select,
    collection: -> { AITStandard.games.map(&:reverse) }
  filter :ait_standard_weapon_eq, label: "Weapon", as: :select,
    collection: -> { AITStandard.weapons.map(&:reverse) }
  filter :ait_standard_badge_eq, label: "Badge", as: :select,
    collection: -> { AITStandard.badges.map(&:reverse) }

  config.sort_order = "date_desc"
  config.create_another = true

  index do
    column :date
    column :user
    column :game, sortable: "standards.game" do |ait_qualification|
      ait_qualification.ait_standard.game
    end
    column :weapon, sortable: "standards.weapon" do |ait_qualification|
      ait_qualification.ait_standard.weapon
    end
    column :badge, sortable: "standards.badge" do |ait_qualification|
      ait_qualification.ait_standard.badge
    end
    column :ait_standard, sortable: "standards.description"
    column :author
    actions defaults: false do |ait_qualification|
      item "View", manage_ait_qualification_path(ait_qualification)
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      if params[:user_id]
        li do
          label "User"
          span f.object.user
        end
      else
        input :user, as: :searchable_select, ajax: true
      end
      input :ait_standard, as: :select,
        collection: AITStandard.order(:game, :weapon, :badge, :description)
          .map { |standard| [standard.with_prefix, standard.id] }
      input :date, as: :datepicker
    end
    f.actions
  end

  before_save do |ait_qualification|
    ait_qualification.author = current_user
  end
end
