class Payment < ApplicationRecord
  has_many :orders, through: :orders_payments
end
