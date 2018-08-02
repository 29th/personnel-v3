class Unit < ApplicationRecord
  has_many :users, through: :assignments
  has_many :permissions
end
