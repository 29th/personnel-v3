class UserAward < ApplicationRecord
  self.table_name = "awardings"
  include HasForumTopic
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :award

  validates :date, presence: true
  validates_date :date
end
