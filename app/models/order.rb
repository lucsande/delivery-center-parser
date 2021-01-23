class Order < ApplicationRecord
  belongs_to :store
  belongs_to :customer
  belongs_to :product
end
