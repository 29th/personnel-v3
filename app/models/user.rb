class User < ApplicationRecord
  self.table_name = 'members'

  has_many :assignments, dependent: :delete_all, foreign_key: 'member_id'
  has_many :units, through: :assignments
  has_many :passes, inverse_of: :user
  belongs_to :rank

  scope :active, -> { joins(:assignments).merge(Assignment.active).distinct }

  nilify_blanks
  validates_presence_of :last_name, :first_name, :rank

  def full_name
    [rank.name, first_name, last_name]
      .reject{ |s| s.nil? or s.empty? }
      .join(' ')
  end

  def short_name
    [rank.abbr, last_name]
      .reject{ |s| s.nil? or s.empty? }
      .join(' ')
  end

  def display_name
    short_name
  end

  def self.create_with_auth(auth)
    create! do |user|
      user.steam_id = auth['uid']
    end
  end

  def has_permission?(permission)
    permissions.pluck('abilities.abbr').include?(permission)
  end

  def has_permission_on_unit?(permission, unit)
    permissions_on_unit(unit).pluck('abilities.abbr').include?(permission)
  end

  def has_permission_on_user?(permission, user)
    permissions_on_user(user).pluck('abilities.abbr').include?(permission)
  end

  def member?
    assignments.active
               .joins(:unit)
               .where(units: { classification: %i[combat staff] })
               .any?
  end

  private
    def permissions
      # TODO: Use Ability instead of assignments? Doesn't matter much...
      assignments.active
                 .joins(:position, unit: { permissions: :ability })
                 .where('unit_permissions.access_level <= positions.access_level')
                 .where('units.active', true)
    end

    def permissions_on_unit(unit)
      permissions.where(unit: unit.path_ids)
    end

    def permissions_on_user(subject)
      subject_path_ids = subject.assignments
                                .active
                                .includes(:unit)
                                .flat_map { |assignment| assignment.unit.path_ids }
                                .uniq

      permissions.where(unit: subject_path_ids)
    end
end
