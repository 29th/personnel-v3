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

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object)
    %w[id date]
  end

  def self.ransackable_associations(_auth_object)
    %w[user old_rank new_rank]
  end
end
