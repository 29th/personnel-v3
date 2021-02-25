class Rank < ApplicationRecord
  include RankImageUploader::Attachment(:image)

  validates_presence_of :name, :abbr, :order
  validates_numericality_of :order, :only_integer => true

  def display_name
    abbr
  end

  def slug
    abbr.gsub(/[^0-9a-zA-Z]/i, '').downcase
  end
end
