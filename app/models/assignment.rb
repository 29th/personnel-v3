class Assignment < ApplicationRecord
  belongs_to :unit
  belongs_to :user
  belongs_to :position

  scope :current, -> {
    where('started_at <= current_date and (ended_at > current_date or ended_at is null)')
  }
end
