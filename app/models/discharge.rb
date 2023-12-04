class Discharge < ApplicationRecord
  self.inheritance_column = nil
  self.implicit_order_column = :date
  include HasForumTopic
  audited

  belongs_to :user, foreign_key: "member_id"

  enum type: {honorable: "Honorable",
              general: "General",
              dishonorable: "Dishonorable"}

  attr_accessor :end_assignments

  validates :user, presence: true
  validates :date, presence: true
  validates_date :date
  validates :type, presence: true
  validates :reason, presence: true

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object)
    %w[id date type]
  end

  def self.ransackable_associations(_auth_object)
    %w[user]
  end
end
