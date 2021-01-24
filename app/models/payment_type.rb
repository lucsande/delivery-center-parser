class PaymentType < ApplicationRecord
  has_many :payments
  # TODO: validate uniqueness and presence of name
  # TODO: upcase name before saving
end