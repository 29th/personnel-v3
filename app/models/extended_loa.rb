class ExtendedLOA < ApplicationRecord
  self.table_name = "eloas"
  audited
  belongs_to :user, foreign_key: "member_id"

  validates :user, presence: true
  validates :start_date, presence: true, timeliness: {type: :date}
  validates :end_date, presence: true, timeliness: {type: :date, after: :start_date}
  validates :return_date, timeliness: {type: :date, after: :start_date}, allow_blank: true
  validates :reason, presence: true

  before_create :set_posting_date

  self.skip_time_zone_conversion_for_attributes = [:posting_date]

  scope :active, ->(date = Date.current) {
    date = date.to_date # strip time component
    where("start_date <= ? AND end_date >= ? AND (return_date IS NULL OR return_date >= ?)", date, date, date)
  }

  def active?(date = Date.current)
    date = date.to_date # strip time component
    date.between?(start_date, end_date) && (!return_date || return_date >= date)
  end

  def duration
    days = end_date - start_date
    seconds = days * 24 * 60 * 60
    ActiveSupport::Duration.build(seconds)
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id start end reason]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end

  private

  def set_posting_date
    self.posting_date = Time.zone.now
  end
end
