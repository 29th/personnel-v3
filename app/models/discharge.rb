class Discharge < ApplicationRecord
  self.inheritance_column = nil
  self.implicit_order_column = :date
  include HasForumTopic
  audited

  belongs_to :user, foreign_key: "member_id"

  enum type: {honorable: "Honorable",
              general: "General",
              dishonorable: "Dishonorable"}

  attr_accessor :end_assignments

  validates :user, presence: true
  validates :date, presence: true
  validates_date :date
  validates :type, presence: true
  validates :reason, presence: true
end
