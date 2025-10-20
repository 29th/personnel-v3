ActiveAdmin.register Assignment do
  belongs_to :user, optional: true, finder: :find_by_slug

  includes :unit, :position, user: :rank

  permit_params do
    permitted = [:start_date, :end_date]
    if params[:action] == "create"
      permitted += [:member_id, :unit_id, :position_id,
        :transfer_from_assignment_id]
    end
    permitted
  end

  filter :unit, collection: -> { Unit.for_dropdown }
  filter :user, as: :searchable_select, ajax: true
  filter :position, collection: -> { Position.for_dropdown }
  filter :start_date
  filter :end_date

  scope :active, default: true
  scope :all

  config.create_another = true

  index download_links: [:json] do
    column :user
    column :unit
    column :position
    column :start_date
    column :end_date
    actions defaults: false do |assignment|
      item "View", manage_assignment_path(assignment)
    end
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
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs "data-controller" => "assignment-transfer",
      "data-assignment-transfer-assignments-url-value" => manage_assignments_path(format: :json) do
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
        f.input :user,
          as: :searchable_select,
          ajax: true,
          input_html: {
            "data-controller" => "jquery-shim",
            "data-action" => "$change->assignment-transfer#loadAssignments",
            "data-assignment-transfer-target" => "user"
          }
        f.input :unit, as: :select, collection: Unit.for_dropdown
        f.input :position, as: :select, collection: Position.for_dropdown

        f.input :transfer_from_assignment_id, as: :select,
          collection: [],
          input_html: {
            "data-assignment-transfer-target": "assignments"
          }
      end

      f.input :start_date
      f.input :end_date
    end
    f.actions
  end

  before_create do |assignment|
    if assignment.transfer_from_assignment_id.present?
      transfer_from_assignment = Assignment.find(assignment.transfer_from_assignment_id)
      authorize transfer_from_assignment, :update?
      transfer_from_assignment.end(assignment.start_date)
    end
  end

  after_save do |assignment|
    UpdateDiscourseRolesJob.perform_later(assignment.user)
  end

  after_destroy do |assignment|
    UpdateDiscourseRolesJob.perform_later(assignment.user)
  end
end
