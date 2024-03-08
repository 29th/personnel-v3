class Assignment < ApplicationRecord
  audited
  belongs_to :unit
  belongs_to :user, foreign_key: "member_id", inverse_of: :assignments
  belongs_to :position

  scope :active, ->(date = Date.current) {
    where("assignments.start_date <= ?", date)
      .merge(where("assignments.end_date > ?", date).or(where(end_date: nil)))
  }

  scope :training, -> {
    joins(:unit).merge(Unit.training)
  }

  scope :not_training, -> {
    joins(:unit).merge(Unit.not_training)
  }

  scope :roster, ->(unit_ids) {
    includes(user: :rank)
      .includes(:position)
      .where(unit_id: unit_ids)
      .order("positions.order DESC, ranks.order DESC")
      .group_by(&:unit_id)
  }

  nilify_blanks
  validates :user, presence: true
  validates :unit, presence: true
  validates :position, presence: true
  validates :start_date, presence: true
  validates_date :start_date
  validates_date :end_date, allow_blank: true

  attr_accessor :transfer_from_assignment_id

  def period
    start_date..(end_date || Date.current)
  end

  def end(end_date = Date.current)
    update(end_date: end_date)
  end

  def self.since(date)
    where("start_date >= ?", date)
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id access_level start_date end_date]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user unit position]
  end
end
