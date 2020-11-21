class UnitForumRole < ApplicationRecord
  self.table_name = 'unit_roles'
  belongs_to :unit

  enum access_level: { member: 0, elevated: 5, leader: 10 }

  enum forum_id: { phpbb: 'PHPBB',
                   smf: 'SMF',
                   vanilla: 'Vanilla',
                   discourse: 'Discourse' }

  validates :forum_id, presence: true
  validates :access_level, presence: true
  validates :role_id, presence: true
  validates :role_id, numericality: { only_integer: true }

  attr_accessor :discourse_role_id, :vanilla_role_id
end
