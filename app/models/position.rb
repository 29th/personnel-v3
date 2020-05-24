class Position < ApplicationRecord
  enum access_level: { member: 0, elevated: 5, leader: 10 }

  scope :active, -> { where(active: true ) }
end
