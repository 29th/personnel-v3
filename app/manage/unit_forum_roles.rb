ActiveAdmin.register UnitForumRole do
  belongs_to :unit, optional: true, finder: :find_by_slug
  permit_params :unit_id, :access_level, :forum_id, :role_id,
    :discourse_role_id
  menu parent: "Permissions"

  includes :unit

  filter :unit, collection: -> { Unit.for_dropdown }
  filter :access_level, as: :select, collection: -> { UnitForumRole.access_levels }
  filter :forum_id, as: :select, collection: -> { UnitForumRole.forum_ids }
  filter :role_id

  index do
    @roles ||= controller.roles
    selectable_column
    column :unit
    column :access_level
    column :role_id do |record|
      @roles[record.forum_id.to_sym][record.role_id]
    end
    column :forum_id
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs "data-controller" => "forum-roles" do
      input :unit, collection: Unit.for_dropdown(f.object&.unit)
      input :access_level, as: :select, collection: UnitForumRole.access_levels.keys
      input :forum_id, as: :select,
        collection: UnitForumRole.forum_ids.map(&:reverse),
        input_html: {
          "data-controller" => "jquery-shim",
          "data-action" => "$change->forum-roles#showForumRoles",
          "data-forum-roles-target" => "forum"
        }
      input :role_id, as: :select, label: "Discourse role",
        collection: controller.roles[:discourse].map(&:reverse),
        input_html: {
          "data-forum-roles-target" => "discourseRoles",
          :name => "unit_forum_role[discourse_role_id]",
          :id => "unit_forum_role_discourse_role_id"
        }
    end
    f.actions
  end

  before_save do |unit_forum_role|
    if unit_forum_role.discourse?
      unit_forum_role.role_id = unit_forum_role.discourse_role_id
    end
  end

  controller do
    def roles
      @roles ||= begin
        discourse = begin
          DiscourseService.new.roles
        rescue Faraday::Error => err
          Appsignal.set_error(err)
          {}
        end
        {discourse: discourse}
      end
    end
  end
end
