class Unit < ApplicationRecord
  has_many :users, through: :assignments
end
