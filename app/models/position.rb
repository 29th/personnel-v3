class Position < ApplicationRecord
  enum access_level: [ :member, :clerk, :leader ]
end
