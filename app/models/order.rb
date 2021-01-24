class Order < ApplicationRecord
  belongs_to :store
  belongs_to :customer
  has_many :products, through: :orders_products
  has_many :payments, through: :orders_payments
end
