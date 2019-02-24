class Rank < ApplicationRecord
  validates_presence_of :name, :abbr, :order
  validates_numericality_of :order, :only_integer => true

  def display_name
    abbr
  end
end
