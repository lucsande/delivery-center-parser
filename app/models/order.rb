class Order < ApplicationRecord
  belongs_to :store
  belongs_to :customer
  has_many :orders_products
  has_many :products, through: :orders_products1818
  has_many :payments

  # TODO: validate uniqueness of marketplace_id IMPORTANT SO WE DON'T PLACE ORDER TWICE
end
