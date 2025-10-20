ActiveAdmin.register Discharge do
  belongs_to :user, optional: true, finder: :find_by_slug

  includes user: :rank

  permit_params :member_id, :type, :date, :reason, :forum_id,
    :topic_id, :end_assignments, :was_reversed

  filter :user, as: :searchable_select, ajax: true
  filter :type, as: :select, collection: -> { Discharge.types.map(&:reverse) }
  filter :date

  index do
    column :date
    column :user
    column :type
    actions defaults: false do |discharge|
      item "View", manage_discharge_path(discharge)
    end
  end

  show do
    attributes_table do
      row :user
      row :date
      row :type
      row :reason
      row :was_reversed
      row :forum_id
      row :topic_id
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      if f.object.new_record?
        f.input :user, as: :searchable_select, ajax: true
      else
        li do
          label "User"
          span f.object.user
        end
      end

      f.input :date
      f.input :type, as: :select, collection: Discharge.types.map(&:reverse)
      f.input :reason
      f.input :was_reversed unless f.object.new_record?
      f.input :forum_id, as: :select, collection: Discharge.forum_ids.map(&:reverse)
      f.input :topic_id, label: "Topic ID"

      if f.object.new_record?
        f.input :end_assignments, as: :boolean, label: "End assignments and update permissions",
          input_html: {checked: "checked"}
      end
    end
    f.actions
  end

  after_create do |discharge|
    if discharge.end_assignments
      discharge.user.end_assignments(discharge.date)
      UpdateDiscourseRolesJob.perform_later(discharge.user)
    end
  end
end
