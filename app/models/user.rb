class User < ApplicationRecord
  has_many :assignments
  has_many :units, through: :assignments
  belongs_to :rank

  def self.create_with_auth(auth)
    create! do |user|
      user.steamid = auth['uid']
    end
  end

  def permissions
    assignments
      .joins(:position, unit: :permissions)
      .where('permissions.access_level <= positions.access_level')
      .pluck(:ability)
  end
end
