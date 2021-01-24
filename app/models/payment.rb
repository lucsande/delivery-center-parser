class Payment < ApplicationRecord
  has_many :orders, through: :orders_products
  belongs_to :payment_type
end
