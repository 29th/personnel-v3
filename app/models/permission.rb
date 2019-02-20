class Permission < ApplicationRecord
  self.table_name = 'unit_permissions'
  enum access_level: { member: 0, elevated: 5, leader: 10 }

  belongs_to :unit
  belongs_to :ability
end
