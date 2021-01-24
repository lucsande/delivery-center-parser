class Order < ApplicationRecord
  belongs_to :store
  belongs_to :customer
  has_many :orders_products
  has_many :products, through: :orders_products
  has_many :orders_payments
  has_many :payments, through: :orders_payments

  # TODO: validate uniqueness of marketplace_id IMPORTANT SO WE DON'T PLACE ORDER TWICE
end
