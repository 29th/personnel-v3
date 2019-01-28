class Permission < ApplicationRecord
  self.table_name = 'unit_permissions'
  enum access_level: [ :member, :clerk, :leader ]

  belongs_to :unit
  belongs_to :ability
end
