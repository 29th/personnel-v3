# for Enlistments
class PreviousUnit
  include StoreModel::Model

  attribute :unit, :string
  attribute :game, :string
  attribute :name, :string
  attribute :rank, :string
  attribute :reason, :string

  validates :unit, presence: true, length: {maximum: 60}
  validates :game, length: {maximum: 60}
  validates :name, length: {maximum: 60}
  validates :rank, length: {maximum: 60}
  validates :reason, presence: true, length: {maximum: 128}

  def new_record?
    attributes.all? { |key, val| val.nil? }
  end
end
