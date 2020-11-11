ActiveAdmin.register UserAward do
  belongs_to :user, optional: true
  belongs_to :award, optional: true
 
  includes :award, user: :rank

  permit_params :member_id, :award_id, :date, :forum_id, :topic_id

  filter :user, collection: -> { User.active.includes(:rank).order(:last_name) }
  filter :award
  filter :date

  config.sort_order = 'date_desc'

  index do
    selectable_column
    column :user
    column :award
    column :date
    # column :forum_topic_url # TODO
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      input :user, collection: User.active.includes(:rank).order(:last_name)
      input :award, collection: Award.order(:title)
      input :date, as: :datepicker
      input :forum_id, as: :select, collection: UserAward.forum_ids.map(&:reverse)
      input :topic_id, label: 'Topic ID'
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
