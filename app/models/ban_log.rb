class BanLog < ApplicationRecord
  self.table_name = "banlog"
  audited

  belongs_to :admin, class_name: "User", foreign_key: "id_admin"
  belongs_to :poster, class_name: "User", foreign_key: "id_poster"

  attribute :date, :date, default: -> { Date.current }

  validates :date, presence: true
  validates_date :date
  validates :roid, presence: true, numericality: {only_integer: true}
  validates :handle, length: {maximum: 32}
  validates :ip, length: {maximum: 20}
  validates :admin, presence: true
  validates :poster, presence: true
  validates :reason, length: {maximum: 1000}

  self.skip_time_zone_conversion_for_attributes = [:unbanned]

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id roid uid guid handle reason comments ip]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[admin]
  end
end
