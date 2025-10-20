ActiveAdmin.register Promotion do
  belongs_to :user, optional: true, finder: :find_by_slug

  includes :new_rank, user: :rank

  permit_params :member_id, :date, :old_rank_id, :new_rank_id, :forum_id,
    :topic_id

  filter :user, as: :searchable_select, ajax: true
  filter :new_rank
  filter :date

  index do
    column :date
    column :user
    column :new_rank
    actions defaults: false do |unit|
      item "View", manage_promotion_path(unit)
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      input :user, as: :searchable_select, ajax: true
      input :old_rank
      input :new_rank
      input :date
      input :forum_id, as: :select, collection: Promotion.forum_ids.map(&:reverse)
      input :topic_id, label: "Topic ID"
    end
    f.actions
  end

  after_save do |promotion|
    promotion.user.refresh_rank
    UpdateDiscourseDisplayNameJob.perform_later(promotion.user)
    GenerateServiceCoatJob.perform_later(promotion.user)
  end

  after_destroy do |promotion|
    promotion.user.refresh_rank
    UpdateDiscourseDisplayNameJob.perform_later(promotion.user)
    GenerateServiceCoatJob.perform_later(promotion.user)
  end
end
