class Discharge < ApplicationRecord
  self.inheritance_column = nil
  self.implicit_order_column = :date
  include HasForumTopic
  audited

  belongs_to :user, foreign_key: "member_id"

  enum :type, {honorable: "Honorable",
              general: "General",
              dishonorable: "Dishonorable"}

  attr_accessor :end_assignments

  attribute :date, :date, default: -> { Date.current }

  validates :user, presence: true
  validates :date, presence: true
  validates_date :date
  validates :type, presence: true
  validates :reason, presence: true

  scope :non_honorable, -> { where.not(type: "Honorable") }

  scope :for_unit, ->(unit) {
    joins(user: :assignments)
      .where(assignments: {unit_id: unit})
      .where("assignments.end_date = discharges.date")
  }

  scope :desc, -> { order(date: :desc) }

  def type_abbr
    {"honorable" => "HD",
     "general" => "GD",
     "dishonorable" => "DD"}[type]
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id date type]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end
end
