require 'spec_helper'
require 'delivery_center/api'

RSpec.describe DeliveryCenter::Api do
  let(:described) { DeliveryCenter::Api }
  let(:payload_path) { File.join('spec', 'fixtures', 'orders', 'marketplace_order_payload.json') }
  let(:marketplace_payload) { JSON.parse(File.read(payload_path)) }

  describe '.place_order' do
    it 'sends order json with X-Sent header' do
      VCR.use_cassette('successful_order_placement') do
        # res = described.place_order
      end
    end

    context 'when API response status is not 200' do
      it 'raises a DeliveryCenter::ApiError' do
        VCR.use_cassette('failed_order_placement') do
          
        end
      end
    end
  end
end
