class OrdersPayment < ApplicationRecord
  belongs_to :payment
  belongs_to :order
end
