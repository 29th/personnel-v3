class Unit < ApplicationRecord
  has_many :users, through: :assignments
  has_many :permissions

  # the database uses a column named `class`, which is a reserved
  # word in ruby. this hack prevents it breaking the app.
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == 'class'
      super
    end
  end
end
