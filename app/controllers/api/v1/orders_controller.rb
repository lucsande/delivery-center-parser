# module for all API controllers
module Api
  # API's first version
  module V1
    # receives orders from marketplace, processes them and then send them to DeliveryCenter's server
    class OrdersController < ApplicationController
      def create
        parsed_payload = Parser::MarketplaceToDeliveryCenter::OrderPayload.parse(params)
        # enviar para o Delivery Center
        # criar registros na base de dados
        # responder request com 200 ou erro
        # escrever docuemtnação
        # TODO
      end
    end
  end
end
