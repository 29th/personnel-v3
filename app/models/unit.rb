class Unit < ApplicationRecord
  has_ancestry
  has_many :assignments
  has_many :users, through: :assignments
  has_many :permissions

  enum game: { dh: 'DH', rs: 'RS', arma3: 'Arma 3', rs2: 'RS2', squad: 'Squad' }
  enum timezone: { est: 'EST', gmt: 'GMT' }
  enum classification: { combat: 'Combat', staff: 'Staff', training: 'Training' }

  scope :active, -> { where(active: true) }

  nilify_blanks
  validates_presence_of :name, :abbr, :classification

  def display_name
    abbr
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
