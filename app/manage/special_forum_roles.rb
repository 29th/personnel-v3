ActiveAdmin.register SpecialForumRole do
  permit_params :special_attribute, :forum_id, :role_id,
    :discourse_role_id
  menu parent: "Permissions"

  scope :all, default: true
  scope :discourse

  filter :special_attribute, as: :select, collection: -> { SpecialForumRole.special_attributes }
  filter :forum_id, as: :select, collection: -> { SpecialForumRole.forum_ids.map(&:reverse) }
  filter :role_id

  index do
    @roles ||= controller.roles
    selectable_column
    column :special_attribute
    column :role_id do |record|
      @roles[record.forum_id.to_sym][record.role_id]
    end
    column :forum_id
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs "data-controller" => "forum-roles" do
      input :special_attribute, as: :select, collection: SpecialForumRole.special_attributes.map(&:reverse)
      input :forum_id, as: :select,
        collection: SpecialForumRole.forum_ids.map(&:reverse),
        input_html: {
          "data-controller" => "jquery-shim",
          "data-action" => "$change->forum-roles#showForumRoles",
          "data-forum-roles-target" => "forum"
        }
      input :role_id, as: :select, label: "Discourse role",
        collection: controller.roles[:discourse].map(&:reverse),
        input_html: {
          "data-forum-roles-target" => "discourseRoles",
          :name => "special_forum_role[discourse_role_id]",
          :id => "special_forum_role_discourse_role_id"
        }
    end
    f.actions
  end

  before_save do |special_forum_role|
    if special_forum_role.discourse?
      special_forum_role.role_id = special_forum_role.discourse_role_id
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
