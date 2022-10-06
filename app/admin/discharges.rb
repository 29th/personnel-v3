ActiveAdmin.register Discharge do
  belongs_to :user, optional: true, finder: :find_by_slug

  includes user: :rank

  permit_params :member_id, :type, :date, :reason, :forum_id,
    :topic_id, :end_assignments, :was_reversed

  # filter :user, collection: -> { User.for_dropdown }
  filter :user_last_name_cont, label: "User last name"
  filter :type
  filter :date

  index do
    selectable_column
    column :user
    column :date
    column :type
    actions
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
        f.input :user, as: :select, collection: User.for_dropdown
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
      discharge.user.update_forum_roles
    end
  end
end
