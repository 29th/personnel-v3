class Assignment < ApplicationRecord
  belongs_to :unit
  belongs_to :user, foreign_key: 'member_id'
  belongs_to :position

  scope :current, -> {
    where('start_date <= current_date and (end_date > current_date or end_date is null)')
  }

  validates_presence_of :user, :unit, :position
end
