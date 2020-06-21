ActiveAdmin.register Pass do
  belongs_to :user, optional: true

  includes user: :rank

  permit_params :member_id, :recruit_id, :start_date, :end_date,
                :type, :reason

  scope :active, default: true
  scope :all

  filter :user, collection: -> { User.active.includes(:rank) }
  filter :start_date
  filter :end_date
  filter :type, as: :select

  index do
    selectable_column
    column :user
    column :start_date
    column :end_date
    column :type
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      input :user, collection: User.active.includes(:rank).order(:last_name)
      input :start_date, as: :datepicker
      input :end_date, as: :datepicker
      input :type, as: :select, collection: Pass.types.map(&:reverse)
      input :reason
    end
    f.actions
  end

  config.sort_order = 'end_date_desc'

  before_create do |pass|
    pass.author = current_user
  end
end
