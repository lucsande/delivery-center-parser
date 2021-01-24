require 'spec_helper'
require 'delivery_center/api'
require 'custom_error/delivery_center/api_error'

RSpec.describe DeliveryCenter::Api do
  let(:described) { DeliveryCenter::Api }
  let(:parsed_order) { build(:parsed_order) } # spec/factories/orders.rb
  let(:api_url) { "https://delivery-center-recruitment-ap.herokuapp.com/" }

  describe '.place_order' do
    it 'sends order json with X-Sent header in correct format to API' do
      VCR.use_cassette('successful_order_placement') do
        httparty_moq_req = HTTParty::Request.new Net::HTTP::Post, api_url
        nethttp_mock_resp = Net::HTTPInternalServerError.new('1.1', 200, 'OK')
        mock_response = HTTParty::Response.new(httparty_moq_req, nethttp_mock_resp, lambda { '' }, body: 'OK')
        allow(HTTParty). to receive(:post) { mock_response }

        req_body = parsed_order.to_json
        req_headers = { 'Content-Type' => 'application/json', 'X-Sent' => Time.now.strftime('%Hh%M - %d/%m/%y') }
        expect(HTTParty).to receive(:post).with(api_url, { body: req_body, headers: req_headers })

        described.place_order(parsed_order)
      end
    end

    context 'when order attributes are all right' do
      it 'return the response from the API with code 200' do
        VCR.use_cassette('successful_order_placement') do
          res = described.place_order(parsed_order)
          expect(res.code).to eq 200
          expect(res.body).to eq 'OK'
        end
      end
    end

    context 'when API response status is not 200' do
      it 'raises a DeliveryCenter::ApiError' do
        VCR.use_cassette('failed_order_placement') do
          invalid_order = {}
          expect { described.place_order(invalid_order) }.to raise_error(DeliveryCenter::ApiError)
        end
      end
    end
  end
end
