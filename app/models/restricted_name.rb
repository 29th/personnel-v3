class RestrictedName < ApplicationRecord
  audited

  belongs_to :user, foreign_key: "member_id"

  validates :name, presence: true, length: {maximum: 40}
  validates :user, presence: true
end
