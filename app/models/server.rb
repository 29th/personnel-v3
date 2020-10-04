class Server < ApplicationRecord
  scope :active, -> { where(active: true ) }
end
