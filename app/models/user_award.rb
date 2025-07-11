class UserAward < ApplicationRecord
  self.table_name = "awardings"
  include HasForumTopic
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :award

  attribute :date, :date, default: -> { Date.current }

  validates :date, presence: true
  validates_date :date

  scope :since_latest_non_honorable_discharge, -> {
    left_joins(user: :non_honorable_discharges)
      .group("awardings.id")
      .having(<<~SQL)
        MAX(discharges.date) IS NULL
        OR awardings.date >= MAX(discharges.date)
      SQL
  }

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id date]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user award]
  end
end
