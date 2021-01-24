class Product < ApplicationRecord
  has_many :orders, through: :orders_products

  # TODO: validate uniqueness and presence of marketplace_id
end
