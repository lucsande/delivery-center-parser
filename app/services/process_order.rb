require 'parser/marketplace_to_delivery_center/order_payload'
require 'delivery_center/api'

# service for parsing orders from the marketplace, send it to Delivery Center and store relevant data in DB
class ProcessOrder
  class << self
    def call(order_payload)
      parsed_order = Parser::MarketplaceToDeliveryCenter::OrderPayload.parse(order_payload)
      res = DeliveryCenter::Api.place_order(parsed_order)
      # TODO: criar registros na base de dados

    # rescue DeliveryCenter::ApiError => e

    end

    private
  end
end

