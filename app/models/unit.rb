class Unit < ApplicationRecord
  include UnitLogoImageUploader::Attachment(:logo)

  has_ancestry orphan_strategy: :restrict
  has_many :assignments
  has_many :users, through: :assignments
  has_many :permissions

  enum game: { dh: 'DH', rs: 'RS', arma3: 'Arma 3', rs2: 'RS2', squad: 'Squad' }
  enum timezone: { est: 'EST', gmt: 'GMT', pst: 'PST' }
  enum classification: { combat: 'Combat', staff: 'Staff', training: 'Training' }

  scope :active, -> { where(active: true) }

  nilify_blanks
  validates :name, presence: true
  validates :abbr, presence: true, length: { maximum: 8 }
  validates :classification, presence: true
  validates :slogan, length: { maximum: 140 }

  def display_name
    abbr
  end

  def slug
    abbr.gsub(/ /, '').downcase
  end

  # NOTE: Applies :active scope to subtree
  # NOTE: You probably want to add .active when using this,
  #       to only get active users
  def subtree_users
    User.joins(:assignments)
        .where(assignments: { unit_id: subtree.active.ids })
  end

  # the database uses a column named `class`, which is a reserved
  # word in ruby. this hack prevents it breaking the app.
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == 'class'
      super
    end
  end
end
