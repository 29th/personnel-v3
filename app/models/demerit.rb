class Demerit < ApplicationRecord
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :author, class_name: "User", foreign_key: "author_member_id"

  enum forum_id: {phpbb: "PHPBB",
                  smf: "SMF",
                  vanilla: "Vanilla",
                  discourse: "Discourse"}

  validates :date, presence: true
  validates_date :date
  validates :user, presence: true
  validates :author, presence: true
  validates :forum_id, presence: true
  validates :topic_id, presence: true, numericality: {only_integer: true}
  validates :reason, presence: true
end
