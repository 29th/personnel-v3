class Promotion < ApplicationRecord
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :old_rank, class_name: "Rank", optional: true
  belongs_to :new_rank, class_name: "Rank"

  enum forum_id: {phpbb: "PHPBB",
                  smf: "SMF",
                  vanilla: "Vanilla",
                  discourse: "Discourse"}

  validates :user, presence: true
  validates :new_rank, presence: true
  validates :date, presence: true
  validates_date :date
  validates :forum_id, presence: true
  validates :topic_id, presence: true, numericality: {only_integer: true}
end
