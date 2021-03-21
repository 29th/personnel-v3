ActiveAdmin.register UnitForumRole do
  permit_params :unit_id, :access_level, :forum_id, :role_id,
                :discourse_role_id, :vanilla_role_id

  includes :unit

  scope :all, default: true
  scope :discourse
  scope :vanilla

  filter :unit, collection: -> { Unit.for_dropdown }
  filter :access_level, as: :select, collection: UnitForumRole.access_levels
  filter :forum_id, as: :select, collection: UnitForumRole.forum_ids
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
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      input :unit, collection: -> { Unit.for_dropdown }
      input :access_level, as: :select, collection: UnitForumRole.access_levels.keys
      input :forum_id, as: :select, collection: UnitForumRole.forum_ids.map(&:reverse)
      input :role_id, as: :select, label: 'Discourse role',
                      collection: controller.roles[:discourse].map(&:reverse),
                      input_html: {
                        name: 'unit_forum_role[discourse_role_id]',
                        id: 'unit_forum_role_discourse_role_id'
                      }
      input :role_id, as: :select, label: 'Vanilla role',
                      collection: controller.roles[:vanilla].map(&:reverse),
                      input_html: {
                        name: 'unit_forum_role[vanilla_role_id]',
                        id: 'unit_forum_role_vanilla_role_id'
                      }
    end
    f.actions

    script do
      raw <<~JS
        function showForumRoleInput (forum) {
          $('#unit_forum_role_discourse_role_id').parent('li').toggle(forum === 'discourse')
          $('#unit_forum_role_vanilla_role_id').parent('li').toggle(forum === 'vanilla')
        }

        forumInput = $('#unit_forum_role_forum_id')
        forumInput.on('change', function (evt) {
          showForumRoleInput(evt.target.value)
        })

        showForumRoleInput(forumInput.val())
      JS
    end
  end

  before_save do |unit_forum_role|
    if unit_forum_role.discourse?
      unit_forum_role.role_id = unit_forum_role.discourse_role_id
    elsif unit_forum_role.vanilla?
      unit_forum_role.role_id = unit_forum_role.vanilla_role_id
    end
  end

  controller do
    def roles
      @roles ||= begin
        discourse = DiscourseService.new().get_roles rescue {}
        vanilla = VanillaService.new().get_roles rescue {}
        { discourse: discourse, vanilla: vanilla }
      end
    end
  end
end
