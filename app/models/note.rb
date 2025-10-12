class Note < ApplicationRecord
  audited max_audits: 10
  belongs_to :user, foreign_key: "member_id"
  belongs_to :author, class_name: "User", foreign_key: "author_member_id"

  enum :access, { # public: 'Public', # inactive
    members_only: "Members Only",
    # personal: 'Personal', # inactive
    squad_level: "Squad Level",
    platoon_level: "Platoon Level",
    company_level: "Company Level",
    battalion_hq: "Battalion HQ",
    # officers_only: 'Officers Only', # inactive
    military_police: "Military Police",
    lighthouse: "Lighthouse"
  }

  validates :access, presence: true
  validates :subject, presence: true, length: {maximum: 120}
  validates :content, presence: true

  before_create :set_date_created, :set_date_modified
  before_update :set_date_modified

  self.skip_time_zone_conversion_for_attributes = [:date_add, :date_mod]

  scope :for_access, ->(access_levels) {
    where(access: access_levels)
  }

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id date_add access subject]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end

  private

  def set_date_created
    self.date_add = Date.current
  end

  def set_date_modified
    self.date_mod = Date.current
  end
end
