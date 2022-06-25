ActiveAdmin.register UserAward do
  belongs_to :user, optional: true

  includes :award, user: :rank

  permit_params :member_id, :award_id, :date, :forum_id, :topic_id

  filter :user, collection: -> { User.for_dropdown }
  filter :award
  filter :date

  config.sort_order = "date_desc"
  config.create_another = true

  index do
    selectable_column
    column :user
    column :award
    column :date
    # column :forum_topic_url # TODO
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      input :user, collection: User.for_dropdown
      input :award, collection: Award.order(:title)
      input :date, as: :datepicker
      input :forum_id, as: :select, collection: UserAward.forum_ids.map(&:reverse)
      input :topic_id, label: "Topic ID"
    end
    f.actions
  end

  after_save do |user_award|
    user_award.user.update_coat
  end

  after_destroy do |user_award|
    user_award.user.update_coat
  end
end
