class Assignment < ApplicationRecord
  audited
  belongs_to :unit
  belongs_to :user, foreign_key: "member_id"
  belongs_to :position

  scope :active, ->(date = Date.current) {
    where("assignments.start_date <= ?", date)
      .merge(where("assignments.end_date > ?", date).or(where(end_date: nil)))
  }

  nilify_blanks
  validates :user, presence: true
  validates :unit, presence: true
  validates :position, presence: true
  validates :start_date, presence: true
  validates_date :start_date
  validates_date :end_date, allow_blank: true

  attr_accessor :transfer_from_unit_id

  def end(end_date = Date.current)
    update(end_date: end_date)
  end
end
