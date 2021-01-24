require 'custom_error/parsing_error'
require 'custom_error/delivery_center/api_error'
# module for all API controllers
module Api
  # API's first version
  module V1
    # receives orders from marketplace, processes them and then send them to DeliveryCenter's server
    class OrdersController < ApplicationController
      # TODO: create Parser class that generates appropriate parser (eg, Parser::MarketplaceToDeliveyCenter::Order) and pass it to ProcessOrder. but while we have integrations with only one Marketplace, it's ok 
      def create
        processed_order = ProcessOrder.call(params)
        render json: processed_order, status: :created
        # TODO
        # order:payents one_to_many, sem join_table
        # escrever testes com erro e sem erro, ver se cria registros na base, se retorna coisa certa, se chama api, etc
        # escrever docs
      rescue ParsingError, DeliveryCenter::ApiError => e
        render json: e, status: :bad_request
      end
    end
  end
end
