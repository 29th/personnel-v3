ActiveAdmin.register Pass do
  belongs_to :user, optional: true, finder: :find_by_slug

  includes user: :rank

  permit_params :member_id, :recruit_id, :start_date, :end_date,
    :type, :reason, bulk_member_ids: []

  batch_create by_param: :bulk_member_ids, max: 5 do |member_id|
    @pass.member_id = member_id
  end

  scope :active, default: true
  scope :all

  filter :user, collection: -> { User.for_dropdown }
  filter :start_date
  filter :end_date
  filter :type, as: :select

  index do
    column :user
    column :start_date
    column :end_date
    column :type do |pass|
      Pass.types[pass.type]
    end
    actions defaults: false do |pass|
      item "View", admin_pass_path(pass)
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      if f.object.persisted?
        input :user, collection: User.for_dropdown(f.object&.user)
      else
        input :bulk_member_ids, collection: User.for_dropdown, label: "User(s)",
          input_html: {multiple: true}
      end
      input :start_date, as: :datepicker
      input :end_date, as: :datepicker
      input :type, as: :select, collection: Pass.types.map(&:reverse)
      input :reason
    end
    f.actions
  end

  config.sort_order = "end_date_desc"

  before_create do |pass|
    pass.author = current_user
  end
end
