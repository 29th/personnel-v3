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

  scope :active, ->(date = Date.current) {
    where("start_date <= ? AND end_date >= ? AND (return_date IS NULL OR return_date >= ?)", date, date, date)
  }

  private

  def set_posting_date
    self.posting_date = Time.zone.now
  end
end
