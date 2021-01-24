class Product < ApplicationRecord
  has_many :orders, through: :orders_products
end
