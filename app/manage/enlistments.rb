ActiveAdmin.register Enlistment do
  belongs_to :user, optional: true, finder: :find_by_slug
  includes user: :rank, liaison: :rank
  includes :unit
  actions :index, :show, :edit, :update
  permit_params :first_name, :middle_name, :last_name, :age, :game, :timezone,
    :country_id, :steam_id, :ingame_name, :recruiter, :experience, :comments,
    previous_units_attributes: [:unit, :game, :name, :rank, :reason, :_destroy]

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
    column :game do |enlistment|
      Enlistment.games[enlistment.game]
    end
    column "Preferred time" do |enlistment|
      Enlistment.timezones[enlistment.timezone]
    end
    column :liaison
    actions
  end

  show title: ->(enlistment) { "Enlistment - #{enlistment.user.short_name}" } do
    columns do
      column do
        attributes_table do
          row :date
          tag_row :status
          row :unit
          row :user
          row :first_name
          row "Middle initial", :middle_name
          row :last_name
          row :age
          row :game do |enlistment|
            Enlistment.games[enlistment.game]
          end
          row "Preferred time" do |enlistment|
            Enlistment.timezones[enlistment.timezone]
          end
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
      end

      column do
        panel "User Details" do
          attributes_table_for enlistment.user do
            row "Personnel User" do |user|
              user
            end
            if enlistment.user.forum_member_id
              row "Discourse User" do |user|
                link_to user.forum_member_username, discourse_url(user: user)
              end
            end
            if enlistment.user.vanilla_forum_member_id
              row "Vanilla User" do |user|
                link_to user.vanilla_forum_member_username, vanilla_url(user: user)
              end
            end
          end
        end

        panel "Linked Forum Users" do
          table_for(enlistment.linked_users) do
            column "Forum" do |row|
              row[:forum].to_s.humanize
            end
            column "User" do |row|
              url = (row[:forum] == :vanilla) ?
                vanilla_url(user: row[:user_id]) :
                discourse_url(user: row[:username])
              link_to row[:username], url
            end
            column "IP" do |row|
              row[:ips].join(", ")
            end
          end
        end

        panel "Linked Ban Logs" do
          table_for(enlistment.linked_ban_logs) do
            column "Date" do |row|
              link_to row.date, manage_ban_log_path(row)
            end
            column :handle
            column :roid
          end
        end
      end
    end
  end

  action_item :edit_user, only: :show, if: -> { authorized?(:edit, enlistment.user) } do
    link_to "Edit User", edit_manage_user_path(enlistment.user)
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      li do
        label "User"
        span link_to f.object.user, manage_user_path(f.object.user) # management path
      end

      f.input :first_name
      f.input :middle_name, label: "Middle initial"
      f.input :last_name
      f.input :age, as: :select, collection: Enlistment::VALID_AGES
      f.input :game, as: :select, collection: Enlistment.games.map(&:reverse)
      f.input :timezone, label: "Preferred time", as: :select,
        collection: Enlistment.timezones.map(&:reverse)
      f.input :country
      f.input :steam_id, label: "Steam ID", as: :string
      f.input :ingame_name
      f.input :recruiter
      f.input :experience
      f.input :comments
    end

    f.has_many :previous_units, heading:  "Previous units",
      allow_destroy: true, class_name: "PreviousUnit" do |pu|
      pu.input :unit
      pu.input :game
      pu.input :name
      pu.input :rank
      pu.input :reason
    end

    f.actions
  end
end
