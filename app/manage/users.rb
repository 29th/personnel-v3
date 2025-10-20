ActiveAdmin.register User do
  belongs_to :unit, optional: true, finder: :find_by_slug

  includes :rank, :country

  actions :index, :show, :edit, :update, :destroy

  permit_params do
    params = [:rank_id, :last_name, :first_name, :middle_name,
      :name_prefix, :steam_id, :forum_member_id, :country_id]

    params += [:forum_member_id] if authorized?(:destroy, resource)

    params
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  searchable_select_options(
    scope: -> {
             User.includes(:rank, :discharges, active_assignments: :unit)
               .order(:last_name, :first_name, :id)
           },
    text_attribute: :last_name,
    additional_payload: ->(record) { {status_detail: record.status_detail} },
    display_text: ->(record) {
      label = "#{record.rank.abbr} #{record.full_name_last_first}"
      label += " (#{record.status_detail})" unless record.status_detail.empty?
      label
    }
  )

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :rank
      f.input :last_name
      f.input :first_name
      f.input :middle_name
      f.input :name_prefix
      f.input :country
      f.input :steam_id, as: :string

      if authorized?(:destroy, resource)
        # Rendering integer field as string imposes incorrect length from schema
        f.input :forum_member_id, as: :string, input_html: {maxlength: nil}
      end
    end
    f.actions
  end

  filter :rank
  filter :last_name
  filter :first_name
  filter :country
  filter :steam_id
  filter :forum_member_id_eq

  scope :active, default: true
  scope :all

  index do
    selectable_column
    column :last_name
    column :first_name
    column :middle_name
    column :rank
    column :country do |user|
      flag_icon(user.country.sym, title: user.country.name) if user.country.present?
    end
    column "Steam ID", :steam_id
    column "Forum ID", :forum_member_id
    actions defaults: false do |user|
      item "View", manage_user_path(user)
    end
  end

  show do
    attributes_table do
      row :id
      row :last_name
      row :first_name
      row :middle_name
      row :rank
      row :country do |user|
        if user.country.present?
          span flag_icon(user.country.sym, title: user.country.name)
          span user.country.name
        end
      end
      row :donated do |user|
        format_donation_balance(FinanceRecord.user_donated(user))
      end
      row "Steam ID", :steam_id do |user|
        link_to user.steam_id, "http://steamcommunity.com/profiles/#{user.steam_id}"
      end
      row "Forum User", :forum_member_id do |user|
        link_to "View forum profile", discourse_url(user: user)
      end
    end
  end

  sidebar "Related records", only: [:show, :edit] do
    ul do
      li link_to "AIT Qualifications", manage_user_ait_qualifications_path(resource) if authorized?(:index, AITQualification)
      li link_to "Assignments", manage_user_assignments_path(resource) if authorized?(:index, Assignment)
      li link_to "Demerits", manage_user_demerits_path(resource) if authorized?(:index, Demerit)
      li link_to "Discharges", manage_user_discharges_path(resource) if authorized?(:index, Discharge)
      li link_to "Enlistments", manage_user_enlistments_path(resource) if authorized?(:index, Enlistment)
      li link_to "Extended LOAs", manage_user_extended_loas_path(resource) if authorized?(:index, ExtendedLOA)
      li link_to "Finance Records", manage_user_finance_records_path(resource) if authorized?(:index, FinanceRecord)
      li link_to "Notes", manage_user_notes_path(resource) if authorized?(:index, Note)
      li link_to "Passes", manage_user_passes_path(resource) if authorized?(:index, Pass)
      li link_to "Promotions", manage_user_promotions_path(resource) if authorized?(:index, Promotion)
      li link_to "User Awards", manage_user_user_awards_path(resource) if authorized?(:index, UserAward)
    end
  end

  member_action :update_forum_roles, method: :post do
    authorize! :update_forum_roles, resource
    UpdateDiscourseRolesJob.perform_now(resource) # synchronous to provide immediate feedback
    redirect_to resource_path, notice: "Forum roles updated"
  end

  action_item :update_forum_roles, only: :show,
    if: proc { authorized?(:update_forum_roles, resource) } do
    link_to "Update forum roles", update_forum_roles_manage_user_path(resource), method: :post
  end

  action_item :view_on_site, only: :show do
    link_to "View on site", user_path(user)
  end

  batch_action :update_forum_roles, if: proc { authorized?(:update_forum_roles, User) } do |ids|
    batch_action_collection.find(ids).each do |user|
      authorize! :update_forum_roles, user
      UpdateDiscourseRolesJob.perform_later(user) # async
    end
    redirect_to collection_path, notice: "Forum roles updated"
  end

  after_save do |user|
    triggering_attributes = [:last_name, :name_prefix, :rank_id, :forum_member_id]
    if triggering_attributes.any? { |attr| user.saved_change_to_attribute(attr) }
      UpdateDiscourseDisplayNameJob.perform_later(user)
      GenerateServiceCoatJob.perform_later(user)
    end
  end
end
