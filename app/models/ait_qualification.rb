class AITQualification < ApplicationRecord
  self.table_name = "qualifications"
  audited

  belongs_to :user, foreign_key: "member_id"
  belongs_to :ait_standard, foreign_key: "standard_id"
  belongs_to :author, class_name: "User", foreign_key: "author_member_id"

  validates :user, presence: true
  validates :ait_standard, presence: true,
    uniqueness: {scope: :user, message: "User already has this AIT Standard"}
  validates :author, presence: true
  validates :date, presence: true, timeliness: {date: true}

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object)
    %w[id date]
  end

  def self.ransackable_associations(_auth_object)
    %w[user ait_standard author]
  end
end
