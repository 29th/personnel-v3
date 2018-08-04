class User < ApplicationRecord
  has_many :assignments
  has_many :units, through: :assignments
  belongs_to :rank

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

  private
    def permissions
      @permissions ||= assignments
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

      # TODO: We probably don't want to memoize this since there's args
      @permissions_on_unit ||= permissions
        .where(is_unit_or_parent, unit.id, unit.id)
    end
end
