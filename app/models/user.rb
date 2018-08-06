class User < ApplicationRecord
  has_many :assignments, dependent: :delete_all
  has_many :units, through: :assignments
  belongs_to :rank

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

  def self.create_with_auth(auth)
    create! do |user|
      user.steamid = auth['uid']
    end
  end

  def has_permission?(permission)
    permissions.pluck(:ability).include?(permission)
  end

  def has_permission_on_unit?(permission, unit)
    permissions_on_unit(unit).pluck(:ability).include?(permission)
  end

  def has_permission_on_user?(permission, user)
    permissions_on_user(user).pluck(:ability).include?(permission)
  end

  private
    def permissions
      @permissions ||= assignments
        .current
        .joins(:position, unit: :permissions)
        .where('permissions.access_level <= positions.access_level')
    end

    def permissions_on_unit(unit)
      is_unit_or_parent = <<~EOF
        units.id = ?
        OR units.path @> (
          SELECT path FROM units WHERE id = ?
        )
      EOF

      # TODO: Do we want to memoize this somehow?
      permissions
        .where(is_unit_or_parent, unit.id, unit.id)
    end

    def permissions_on_user(user)
      units = user.assignments.current.map(&:unit)
      unit_ids = units.pluck(:id)

      is_unit_or_parent = <<~EOF
        units.id IN (?)
        OR units.path @> array(
          SELECT path FROM units WHERE id IN (?)
        )
      EOF

      # TODO: Do we want to memoize this somehow?
      permissions
        .where(is_unit_or_parent, unit_ids, unit_ids)
    end
end
