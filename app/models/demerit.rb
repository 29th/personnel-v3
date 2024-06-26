class Demerit < ApplicationRecord
  include HasForumTopic
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :author, class_name: "User", foreign_key: "author_member_id"

  attribute :date, :date, default: -> { Date.current }

  validates :date, presence: true
  validates_date :date
  validates :user, presence: true
  validates :author, presence: true
  validates :reason, presence: true

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id date reason]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end
end
