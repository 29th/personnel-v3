ActiveAdmin.register Enlistment do
  belongs_to :user, optional: true, finder: :find_by_slug
  includes user: :rank, liaison: :rank
  includes :unit
  includes recruiter_user: :rank
  actions :index, :show, :edit, :update
  permit_params do
    params = [
      :age, :game, :timezone, :ingame_name, :discord_username, :recruiter, :experience, :comments,
      previous_units_attributes: [
        :unit, :game, :name, :rank, :reason, :_destroy
      ],
      user_attributes: [
        :first_name, :middle_name, :last_name, :country_id, :steam_id
      ]
    ]

    params += [:member_id] if authorized?(:transfer, resource)
    params += [:status, :unit_id, :recruiter_member_id] if authorized?(:process_enlistment, resource)
    params += [:liaison_member_id] if authorized?(:assign_liaison, resource)

    params
  end

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
  filter :recruiter_user, as: :searchable_select, ajax: true, label: "Recruiter"

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
    column :recruiter_user, label: "Recruiter"
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
          row :first_name do |enlistment|
            enlistment.user.first_name
          end
          row "Middle initial" do |enlistment|
            enlistment.user.middle_name
          end
          row :last_name do |enlistment|
            enlistment.user.last_name
          end
          row :age
          row :game do |enlistment|
            Enlistment.games[enlistment.game]
          end
          row "Preferred time" do |enlistment|
            Enlistment.timezones[enlistment.timezone]
          end
          row :liaison

          row :country do |enlistment|
            country = enlistment.user.country
            if country.present?
              span flag_icon(country.sym, title: country.name)
              span country.name
            end
          end
          row "Steam ID", :steam_id do |enlistment|
            link_to enlistment.user.steam_id, "http://steamcommunity.com/profiles/#{enlistment.user.steam_id}" if enlistment.user.steam_id.present?
          end

          row :ingame_name
          row :discord_username
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

      if authorized?(:analyze, enlistment)
        column do
          panel "User Details" do
            attributes_table_for enlistment.user do
              row "Personnel User" do |user|
                span user
                span " - "
                span link_to "Manage", manage_user_path(user)
                span " - "
                span link_to "Public profile", user_path(user) if policy(user).service_record?
              end
              if enlistment.user.forum_member_id
                row "Discourse User" do |user|
                  link_to user.forum_member_username, discourse_url(user: user)
                rescue Faraday::Error => err
                  error_tag(err)
                end
              end
              if enlistment.user.forum_member_id
                row "Discourse Email" do |user|
                  user.forum_member_email
                rescue Faraday::Error => err
                  error_tag(err)
                end
              end
              if enlistment.user.vanilla_forum_member_id
                row "Vanilla User" do |user|
                  user.vanilla_forum_member_id
                end
              end
            end
          end

          users_with_matching_name = enlistment.users_with_matching_name
            .order(:last_name, :first_name, :id)
            .page(params[:page])
            .per(5)

          if users_with_matching_name.any?
            panel "Users with matching name", id: "users-with-matching-name" do
              paginated_collection(users_with_matching_name, download_links: false) do
                table_for(users_with_matching_name) do
                  column "User" do |user|
                    label = "#{user.rank.abbr} #{user.full_name_last_first}"
                    link_to label, manage_user_path(user)
                  end
                  column "Status" do |user|
                    user.status_detail
                  end
                end
              end
            end
          end

          if enlistment.linked_users_by_steam_id.any?
            panel "Linked Users by Steam ID", id: "linked-users-by-steam-id" do
              table_for(enlistment.linked_users_by_steam_id) do
                column "User" do |user|
                  link_to user, manage_user_path(user)
                end
                column "Steam ID", :steam_id do |user|
                  link_to user.steam_id, "http://steamcommunity.com/profiles/#{user.steam_id}"
                end
              end
            end
          end

          panel "Linked Forum Users", id: "linked-forum-users" do
            table_for(enlistment.linked_forum_users) do
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
          rescue Faraday::Error => err
            error_tag(err)
          end

          panel "Linked Ban Logs", id: "linked-ban-logs" do
            table_for(enlistment.linked_ban_logs) do
              column "Date" do |row|
                link_to row.date, manage_ban_log_path(row)
              end
              column :handle
              column :roid
            end
          rescue Faraday::Error => err
            error_tag(err)
          end
        end
      end
    end

    panel "Forum Replies" do
      if enlistment.discourse?
        render "discourse_embed", {topic_id: enlistment.topic_id}
      elsif enlistment.vanilla?
        render "vanilla_embed", {id: enlistment.id, topic_id: enlistment.topic_id}
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.has_many :user, new_record: false do |u|
      u.input :first_name
      u.input :middle_name, label: "Middle initial"
      u.input :last_name
      u.input :steam_id, label: "Steam ID", as: :string
      u.input :country
    end

    f.inputs "Enlistment" do
      f.input :age, as: :select, collection: Enlistment::VALID_AGES
      f.input :game, as: :select, collection: Enlistment.games.map(&:reverse)
      f.input :timezone, label: "Preferred time", as: :select,
        collection: Enlistment.timezones.map(&:reverse)
      f.input :ingame_name
      f.input :discord_username
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

  action_item :process_enlistment, only: :show,
    if: proc { authorized?(:process_enlistment, enlistment) } do
    link_to "Process Enlistment", process_enlistment_manage_enlistment_path(enlistment)
  end

  member_action :process_enlistment, method: [:get, :patch] do
    if request.patch?
      update! do |success, failure|
        success.html { redirect_to resource_path, notice: "Enlistment processed" }
        failure.html { render :process_enlistment }
      end
    else
      render :process_enlistment
    end
  end

  action_item :transfer, only: :show,
    if: proc { authorized?(:transfer, enlistment) } do
    link_to "Transfer Enlistment", transfer_manage_enlistment_path(enlistment)
  end

  member_action :transfer, method: :get do
    render :transfer
  end

  after_save do |enlistment|
    if enlistment.saved_change_to_status? || enlistment.saved_change_to_unit_id?
      if enlistment.status == "accepted"
        enlistment.destroy_assignments
        enlistment.create_assignment!
        UpdateDiscourseDisplayNameJob.perform_later(enlistment.user)
      elsif enlistment.status == "awol"
        enlistment.end_assignments
      else
        enlistment.destroy_assignments
      end
    elsif (enlistment.user.saved_change_to_last_name? ||
        enlistment.user.saved_change_to_name_prefix?) &&
        enlistment.status == "accepted"
      UpdateDiscourseDisplayNameJob.perform_later(enlistment.user)
    end
  end
end
