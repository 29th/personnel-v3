class UserAward < ApplicationRecord
  audited
  self.table_name = 'awardings'
  belongs_to :user, foreign_key: 'member_id'
  belongs_to :award

  enum forum_id: { phpbb: 'PHPBB',
                   smf: 'SMF',
                   vanilla: 'Vanilla',
                   discourse: 'Discourse' }

  validates :date, presence: true
  validates_date :date
  validates :forum_id, presence: true
  validates :topic_id, presence: true, numericality: { only_integer: true }
end
