class UserAward < ApplicationRecord
  self.table_name = "awardings"
  include HasForumTopic
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :award

  validates :date, presence: true
  validates_date :date
  
  private

  def self.ransackable_attributes(_auth_object)
    %w(id date)
  end

  def self.ransackable_associations(_auth_object)
    %w(user award)
  end
end
