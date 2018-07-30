class Assignment < ApplicationRecord
  belongs_to :unit
  belongs_to :user
  belongs_to :position
end
