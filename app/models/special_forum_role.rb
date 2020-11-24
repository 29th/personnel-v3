class SpecialForumRole < ApplicationRecord
  self.table_name = 'special_roles'

  enum special_attribute: {
    'everyone': 'everyone',
    'member': 'member',
    'officer': 'officer',
    'honorably_discharged': 'honorably_discharged',
  }

  enum forum_id: { vanilla: 'Vanilla',
                   discourse: 'Discourse' }

  validates :special_attribute, presence: true
  validates :forum_id, presence: true
  validates :role_id, presence: true
  validates :role_id, numericality: { only_integer: true }

  attr_accessor :discourse_role_id, :vanilla_role_id
  end
