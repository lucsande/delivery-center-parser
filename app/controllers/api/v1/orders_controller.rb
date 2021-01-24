require 'custom_error/parsing_error'
require 'custom_error/delivery_center/api_error'
# module for all API controllers
module Api
  # API's first version
  module V1
    # receives orders from marketplace, processes them and then send them to DeliveryCenter's server
    class OrdersController < ApplicationController
      def create
        processed_order = ProcessOrder.call(params)
        # responder request com 200 ou erro
        # escrever testes com erro e sem erro, ver se cria registros na base, se retorna coisa certa, se chama api, etc
        # escrever docs
        # TODO
      rescue ParsingError, DeliveryCenter::ApiError => e
        render json: e, status: :bad_request
      end
    end
  end
end
