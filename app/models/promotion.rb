class Promotion < ApplicationRecord
  include HasForumTopic
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :old_rank, class_name: "Rank", optional: true
  belongs_to :new_rank, class_name: "Rank"

  validates :user, presence: true
  validates :new_rank, presence: true
  validates :date, presence: true
  validates_date :date

  def demotion?
    old_rank.present? && old_rank.order > new_rank.order
  end
end
