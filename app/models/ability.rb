class Ability < ApplicationRecord
  has_many :permissions
  audited

  validates_presence_of :name, :abbr
end
