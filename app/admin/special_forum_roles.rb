ActiveAdmin.register SpecialForumRole do
  permit_params :special_attribute, :forum_id, :role_id,
    :discourse_role_id, :vanilla_role_id

  scope :all, default: true
  scope :discourse
  scope :vanilla

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
    f.semantic_errors(*f.object.errors.keys)
    f.inputs "data-controller" => "forum-roles" do
      input :special_attribute, as: :select, collection: SpecialForumRole.special_attributes.map(&:reverse)
      input :forum_id, as: :select,
                       collection: SpecialForumRole.forum_ids.map(&:reverse),
                       input_html: {
                         "data-controller" => "select2-shim",
                         "data-action" => "forum-roles#showForumRoles",
                         "data-forum-roles-target" => "forum"
                       }
      input :role_id, as: :select, label: "Discourse role",
                      collection: controller.roles[:discourse].map(&:reverse),
                      input_html: {
                        "data-forum-roles-target" => "discourseRoles",
                        :name => "special_forum_role[discourse_role_id]",
                        :id => "special_forum_role_discourse_role_id"
                      }
      input :role_id, as: :select, label: "Vanilla role",
                      collection: controller.roles[:vanilla].map(&:reverse),
                      input_html: {
                        "data-forum-roles-target" => "vanillaRoles",
                        :name => "special_forum_role[vanilla_role_id]",
                        :id => "special_forum_role_vanilla_role_id"
                      }
    end
    f.actions
  end

  before_save do |special_forum_role|
    if special_forum_role.discourse?
      special_forum_role.role_id = special_forum_role.discourse_role_id
    elsif special_forum_role.vanilla?
      special_forum_role.role_id = special_forum_role.vanilla_role_id
    end
  end

  controller do
    def roles
      @roles ||= begin
        discourse = begin
          DiscourseService.new.get_roles
        rescue
          {}
        end
        vanilla = begin
          VanillaService.new.get_roles
        rescue
          {}
        end
        {discourse: discourse, vanilla: vanilla}
      end
    end
  end
end
