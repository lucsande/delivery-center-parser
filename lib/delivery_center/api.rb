# module concerning the DeliveryCenter system
module DeliveryCenter
  # interacts with Delivery Center's API
  class Api
    @base_url = 'https://delivery-center-recruitment-ap.herokuapp.com/'

    class << self
      def place_order(order)
        headers = { 'Content-Type' => 'application/json', 'X-Sent' => Time.now.strftime('%Hh%M - %d/%m/%y') }
        res = HTTParty.post(@base_url, body: order.to_json, headers: headers )

        raise DeliveryCenter::ApiError, res.body unless res.code == 200

        res
      end
    end
  end
end
