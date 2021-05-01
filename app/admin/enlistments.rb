ActiveAdmin.register Enlistment do
  belongs_to :user, optional: true, finder: :find_by_slug
  includes user: :rank, liaison: :rank
  includes :unit
  actions :index, :show
  permit_params :member_id, :liaison_member_id, :recruiter_member_id,
    :country_id, :unit_id, :status, :timezone, :game, :ingame_name, :steam_id,
    :first_name, :middle_name, :last_name, :age, :experience, :recruiter,
    :previous_units, :comments

  config.sort_order = "date_desc"

  scope :all, default: true
  scope :pending
  scope :accepted
  scope :denied
  scope :withdrawn
  scope :awol

  filter :date
  filter :user_last_name_cont, label: "Last name"
  filter :game, as: :select, collection: Enlistment.games.map(&:reverse)
  filter :timezone, as: :select, collection: Enlistment.timezones.map(&:reverse)

  index do
    selectable_column
    column :date
    tag_column :status
    column :unit
    column :user
    column :game
    column :timezone
    column :liaison
    actions
  end

  show do
    attributes_table do
      row :date
      tag_row :status
      row :unit
      row :user
      row :first_name
      row :middle_name
      row :last_name
      row :age
      row :game
      row :timezone
      row :liaison

      row :country do |enlistment|
        if enlistment.country.present?
          span flag_icon(enlistment.country.sym, title: enlistment.country.name)
          span enlistment.country.name
        end
      end
      row "Steam ID", :steam_id do |enlistment|
        link_to enlistment.steam_id, "http://steamcommunity.com/profiles/#{enlistment.steam_id}" if enlistment.steam_id.present?
      end

      row :ingame_name
      row :recruiter do |enlistment|
        div enlistment.recruiter
        span link_to enlistment.recruiter_user if enlistment.recruiter_user.present?
      end
      row :previous_units do |enlistment|
        unless enlistment.previous_units.empty?
          table_for enlistment.previous_units do
            column :unit
            column :game
            column :name
            column :rank
            column :reason
          end
        end
      end
      row :experience do |enlistment|
        simple_format enlistment.experience
      end
      row :comments
    end

    panel "Additional Information" do
      table_for(enlistment.linked_users) do
        column "User" do |row|
          link_to row[:name], row[:profile_url]
        end
        column "IP" do |row|
          row[:ips].join(", ")
        end
      end
    end
  end
end
