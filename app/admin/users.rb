ActiveAdmin.register User do
  belongs_to :unit, optional: true

  includes :rank, :country

  actions :index, :show, :edit, :update

  permit_params :rank_id, :last_name, :first_name, :middle_name,
    :name_prefix, :steam_id, :forum_member_id, :country_id

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

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
    end
    f.actions
  end

  filter :rank
  filter :last_name
  filter :first_name
  filter :country
  filter :steam_id
  filter :forum_member_id

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
      item "View", admin_user_path(user)
    end
  end

  show do
    attributes_table do
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
      row "Steam ID", :steam_id do |user|
        link_to user.steam_id, "http://steamcommunity.com/profiles/#{user.steam_id}"
      end
      row "Forum ID", :forum_member_id do |user|
        link_to user.short_name, "https://forums.29th.org/profile/#{user.forum_member_id}/#{user.short_name}"
      end
    end
  end

  sidebar "Related records", only: [:show, :edit] do
    ul do
      li link_to "AIT Qualifications", admin_user_ait_qualifications_path(resource) if authorized?(:index, AITQualification)
      li link_to "Assignments", admin_user_assignments_path(resource) if authorized?(:index, Assignment)
      li link_to "Demerits", admin_user_demerits_path(resource) if authorized?(:index, Demerit)
      li link_to "Discharges", admin_user_discharges_path(resource) if authorized?(:index, Discharge)
      li link_to "Extended LOAs", admin_user_extended_loas_path(resource) if authorized?(:index, ExtendedLOA)
      li link_to "Finance Records", admin_user_finance_records_path(resource) if authorized?(:index, FinanceRecord)
      li link_to "Notes", admin_user_notes_path(resource) if authorized?(:index, Note)
      li link_to "Passes", admin_user_passes_path(resource) if authorized?(:index, Pass)
      li link_to "Promotions", admin_user_promotions_path(resource) if authorized?(:index, Promotion)
      li link_to "User Awards", admin_user_user_awards_path(resource) if authorized?(:index, UserAward)
    end
  end

  member_action :update_forum_roles, method: :post do
    authorize! :update_forum_roles, resource
    resource.update_forum_roles
    redirect_to resource_path, notice: "Forum roles updated"
  end

  action_item :update_forum_roles, only: :show,
    if: proc { authorized?(:update_forum_roles, resource) } do
    link_to "Update forum roles", update_forum_roles_admin_user_path(resource), method: :post
  end

  batch_action :update_forum_roles, if: proc { authorized?(:update_forum_roles, User) } do |ids|
    batch_action_collection.find(ids).each do |user|
      authorize! :update_forum_roles, user
      user.update_forum_roles
    end
    redirect_to collection_path, notice: "Forum roles updated"
  end

  before_save do |user|
    if user.last_name_changed? || user.name_prefix_changed? || user.rank_id_changed?
      user.update_forum_display_name
      user.update_coat
    end
  end
end
