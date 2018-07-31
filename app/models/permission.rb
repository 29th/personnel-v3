class Permission < ApplicationRecord
  enum access_level: [ :member, :clerk, :leader ]

  belongs_to :unit
end
