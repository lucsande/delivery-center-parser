class Customer < ApplicationRecord
  has_many :orders

  # TODO: validate uniqueness and presence of marketplace_id
end
