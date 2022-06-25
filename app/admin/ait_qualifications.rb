ActiveAdmin.register AITQualification do
  belongs_to :user, optional: true
  actions :index, :show, :new, :create, :destroy
  includes user: :rank, author: :rank
  includes :ait_standard
  permit_params :member_id, :standard_id, :author_member_id, :date
  menu parent: "AIT"

  filter :user, as: :select, collection: -> { User.for_dropdown }
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
    selectable_column
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
    actions
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
        input :user, collection: User.for_dropdown
      end
      input :ait_standard, member_label: :with_prefix
      input :date, as: :datepicker
    end
    f.actions
  end

  before_save do |ait_qualification|
    ait_qualification.author = current_user
  end
end
