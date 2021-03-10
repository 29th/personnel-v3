ActiveAdmin.register BanLog do
  includes poster: :rank
  includes admin: :rank

  permit_params :date, :handle, :roid, :uid, :guid, :ip, :id_admin,
                :reason, :comments

  filter :admin, collection: -> { User.active.includes(:rank).order(:last_name) }
  filter :date
  filter :roid_or_uid_or_guid_or_handle_or_reason_or_comments_or_ip_cont, as: :string, label: 'Contains'

  config.sort_order = 'date_desc'

  index do
    selectable_column
    column :date
    column :handle
    column :roid
    column :admin
    actions
  end

  show do
    attributes_table do
      row :date
      row :handle
      row :roid
      row :uid
      row :guid
      row :ip
      row :admin
      row :poster
      row :reason
      row :comments
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :date
      f.input :handle
      f.input :roid, label: 'ROID'
      f.input :uid, label: 'Unique ID'
      f.input :guid, label: 'GUID'
      f.input :ip, label: 'IP Address'
      f.input :admin, as: :select, collection: User.active.includes(:rank).order(:last_name)
      f.input :reason
      f.input :comments
    end
    f.actions
  end

  before_create do |ban_log|
    ban_log.poster = current_user
  end
end
