# module concerning the DeliveryCenter system
module DeliveryCenter
  # interacts with Delivery Center's API
  class Api
    @base_url = 'https://delivery-center-recruitment-ap.herokuapp.com/'

    class << self
      def place_order(order)
        headers = { 'Content-Type' => 'application/json', 'X-Sent' => Time.now.strftime('%Hh%M - %d/%m/%y') }
        response = HTTParty.post(@base_url, body: order.to_json, headers: headers)

        raise DeliveryCenter::ApiError, response.body unless response.code == 200

        response
      end
    end
  end
end
