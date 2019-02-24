ActiveAdmin.register User do
  permit_params :rank, :last_name, :first_name, :middle_name, :name_prefix, # :country_id
    :steam_id, :forum_member_id

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :rank
      f.input :last_name
      f.input :first_name
      f.input :middle_name
      f.input :name_prefix
      # f.input :country
      f.input :steam_id, :as => :string
      f.input :forum_member_id
    end
    f.actions
  end

  filter :rank
  filter :last_name
  filter :first_name
  # filter :country
  filter :steam_id
  filter :forum_member_id

  index do
    selectable_column
    column :last_name
    column :first_name
    column :middle_name
    column :rank
    column :country
    column 'Steam ID', :steam_id
    column 'Forum ID', :forum_member_id
    actions
  end
end
