class Ability < ApplicationRecord
  has_many :permissions

  validates_presence_of :name, :abbr
end
