class Assignment < ApplicationRecord
  belongs_to :unit
  belongs_to :user, foreign_key: 'member_id'
  belongs_to :position

  scope :active, -> {
    arel = Assignment.arel_table
    where(arel[:start_date].lteq(Date.current)
          .and(arel[:end_date].gt(Date.current)
               .or(arel[:end_date].eq(nil))))
  }

  validates_presence_of :user, :unit, :position
end
