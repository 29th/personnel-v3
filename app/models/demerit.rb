class Demerit < ApplicationRecord
  include HasForumTopic
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :author, class_name: "User", foreign_key: "author_member_id"

  validates :date, presence: true
  validates_date :date
  validates :user, presence: true
  validates :author, presence: true
  validates :reason, presence: true
end
