class Permission < ApplicationRecord
  self.table_name = 'unit_permissions'
  audited
  enum access_level: { member: 0, elevated: 5, leader: 10 }

  belongs_to :unit
  belongs_to :ability

  validates_presence_of :unit, :ability, :access_level
end
