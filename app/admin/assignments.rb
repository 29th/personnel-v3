ActiveAdmin.register Assignment do
  belongs_to :user, optional: true

  includes :unit, :position, user: :rank

  permit_params do
    permitted = [:start_date, :end_date]
    if params[:action] == "create"
      permitted += [:member_id, :unit_id, :position_id,
        :transfer_from_unit_id]
    end
    permitted
  end

  filter :unit, collection: -> { Unit.active.order(:ancestry, :name) }
  filter :user, collection: -> { User.active.includes(:rank).order(:last_name) }
  filter :position, collection: -> { Position.active.order(:name) }
  filter :start_date
  filter :end_date

  scope :active, default: true
  scope :all

  index do
    selectable_column
    column :user
    column :unit
    column :position
    column :start_date
    column :end_date
    actions
  end

  show do
    attributes_table do
      row :user
      row :unit
      row :position
      row :start_date
      row :end_date
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      if f.object.persisted?
        li do
          label "User"
          span f.object.user
        end
        li do
          label "Unit"
          span f.object.unit.abbr
        end
        li do
          label "Position"
          span f.object.position.name
        end
      else
        f.input :user, as: :select, collection: User.active.includes(:rank).order(:last_name)
        f.input :unit, as: :select, collection: Unit.active.order(:ancestry, :name)
        f.input :position, as: :select, collection: Position.active.order(:name)

        f.input :transfer_from_unit_id, as: :select, collection: []
      end

      f.input :start_date
      f.input :end_date
    end
    f.actions
  end

  before_create do |assignment|
    if assignment.transfer_from_unit_id.present?
      transfer_from_unit = Assignment.find_by_unit_id!(assignment.transfer_from_unit_id)
      authorize transfer_from_unit, :update?
      transfer_from_unit.end(assignment.start_date)
    end
  end

  after_save do |assignment|
    assignment.user.update_forum_roles
  end

  after_destroy do |assignment|
    assignment.user.update_forum_roles
  end
end
