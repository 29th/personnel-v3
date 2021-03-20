class Assignment < ApplicationRecord
  audited
  belongs_to :unit
  belongs_to :user, foreign_key: 'member_id'
  belongs_to :position

  scope :active, -> {
    arel = Assignment.arel_table
    where(arel[:start_date].lteq(Date.current)
          .and(arel[:end_date].gt(Date.current)
               .or(arel[:end_date].eq(nil))))
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
