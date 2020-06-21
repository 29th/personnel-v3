ActiveAdmin.register Assignment do
  belongs_to :user, optional: true
  belongs_to :unit, optional: true

  includes :unit, :position, user: :rank
  actions :index, :show

  permit_params :member_id, :unit_id, :position_id, :start_date,
                :end_date

  filter :unit, collection: -> { Unit.active.order(:ancestry, :name) }
  filter :user, collection: -> { User.active.includes(:rank).order(:last_name) }
  filter :position, collection: -> { Position.active.order(:name) }
  filter :start_date
  filter :end_date

  scope :active, default: true
  scope :all

  index do
    selectable_column
    column :unit
    column :user
    column :position
    column :start_date
    column :end_date
    actions
  end
end
