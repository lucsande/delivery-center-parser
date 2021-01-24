require 'rails_helper'

RSpec.describe 'Api::V1::Orders', type: :request do
  describe 'POST create' do
    let(:route) { '/api/v1/orders' }
    let(:payload_path) { File.join('spec', 'fixtures', 'orders', 'marketplace_order_payload.json') }
    let(:marketplace_payload_json) { File.read(payload_path) }
    let(:marketplace_payload) { JSON.parse(File.read(payload_path)) }
    let(:parsed_payload) { build(:parsed_order) } # spec/factories/orders.rb

    
    context 'when request body has json with all required order fields' do
      before(:each) { VCR.insert_cassette('successful_order_placement') }
      after(:each) { VCR.eject_cassette('successful_order_placement') }

      let(:request) { { headers: { 'Content-type' => 'application/json' }, params: marketplace_payload_json } }

      it 'returns the placed order json with status 201' do
        post(route, request)

        expect(response.content_type).to eq('application/json')
        expect(response).to have_http_status(:created)
      end

      it 'creates order records in DB' do
        expect { post(route, request) }.to change(Order, :count).by(+1)
        expect(response).to have_http_status(:created)
        expect(response.body).to eq(parsed_payload.to_json)
      end

      it 'saves payload received in the new order record created with extra infor about Rails request processing' do
        post(route, request)

        original_payload = JSON.parse(marketplace_payload_json)
        original_payload = original_payload.merge('action' => 'create').merge('controller' => 'api/v1/orders')
        saved_payload = JSON.parse(Order.last.marketplace_order_payload)
        saved_payload.delete('order') # rails added 'order' because some attr in params matched Order attributes 

        expect(saved_payload).to eq(original_payload)
      end

      context 'when customer already exists in db' do
        it 'uses existing customer to create new order record' do
          buyer = marketplace_payload['buyer']
          customer = Customer.create({ marketplace_id: buyer['id'], name: buyer['nickname'], email: buyer['email'],
                                       contact: buyer['phone']['area_code'].to_s + buyer['phone']['number'] })

          expect { post(route, request) }.not_to change(Customer, :count)
          expect(Order.last.customer).to eq(customer)
        end
      end

      context 'when store already exists in db' do
        it 'uses existing store to create new order record' do
          store = Store.create(marketplace_id: marketplace_payload['store_id'])

          expect { post(route, request) }.not_to change(Store, :count)
          expect(Order.last.store).to eq(store)
        end
      end

      context 'when product already exists in db' do
        it 'uses existing product to create new order record' do
          products = []
          marketplace_payload['order_items'].each do |item|
            item = item['item']

            prod = Product.create(name: item['title'], price: item['unit_price'], marketplace_id: item['id'])
            products.push(prod)
          end

          expect { post(route, request) }.not_to change(Product, :count)
          Order.last.products.each_with_index { |prod, index| expect(prod).to eq(products[index]) }
        end
      end

      context 'when payment already exists in db' do
        it 'uses existing payment type to create new order record' do
          marketplace_payload['payments'].each do |pay|
            PaymentType.find_or_create_by(name: pay['payment_type'].upcase)
          end
          payment_types_before_req = PaymentType.all

          expect { post(route, request) }.to change(Payment, :count).by marketplace_payload['payments'].count
          expect(PaymentType.all.count).to eq(payment_types_before_req.count)
        end
      end
    end

    context 'when request body doesnt have all the required order fields' do
      before(:each) { VCR.insert_cassette('failed_order_placement') }
      after(:each) { VCR.eject_cassette('failed_order_placement') }
      let(:request) { { headers: { 'Content-type' => 'application/json' }, params: {} } }

      it 'returns error with status 400' do
        post(route, request)
        expect(response).to have_http_status(:bad_request)
      end

      it "doesn't even tries to make request to DeliveryCenter API" do
        expect(DeliveryCenter::Api).not_to receive(:place_order)
      end
  
      it 'logs the order that could not be placed' do
        expect { post(route, request) }.to change(FailedOrderLog, :count).by(+1)
      end
    end
  end
end
