class Cadet < User
  attr_accessor :unit_id

  # Idea: use on: :graduation to move to User model without breaking saving
  validates_associated :assignments, :promotions, :user_awards
end
