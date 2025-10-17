ActiveAdmin.register UserAward do
  belongs_to :user, optional: true, finder: :find_by_slug

  includes :award, user: :rank

  permit_params :member_id, :award_id, :date, :forum_id, :topic_id

  filter :user, as: :searchable_select, ajax: true
  filter :award
  filter :date

  config.sort_order = "date_desc"
  config.create_another = true

  index do
    column :date
    column :user
    column :award
    # column :forum_topic_url # TODO
    actions defaults: false do |user_award|
      item "View", manage_user_award_path(user_award)
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      input :user, as: :searchable_select, ajax: true
      input :award, collection: Award.order(:title)
      input :date, as: :datepicker
      input :forum_id, as: :select, collection: UserAward.forum_ids.map(&:reverse)
      input :topic_id, label: "Topic ID"
    end
    f.actions
  end

  after_save do |user_award|
    GenerateServiceCoatJob.perform_later(user_award.user)
  end

  after_destroy do |user_award|
    GenerateServiceCoatJob.perform_later(user_award.user)
  end
end
