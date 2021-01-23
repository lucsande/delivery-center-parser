require 'spec_helper'
require 'parser/marketplace_to_delivery_center/order_payload'

RSpec.describe Parser::MarketplaceToDeliveryCenter::OrderPayload do
  let(:described) { Parser::MarketplaceToDeliveryCenter::OrderPayload }
  let(:payload_path) { File.join('spec', 'fixtures', 'orders', 'marketplace_order_payload.json') }
  let(:marketplace_payload) { JSON.parse(File.read(payload_path)) }

  parsed_payload = {
    externalCode: 9987071, storeId: 282, dtOrderCreate: "2019-06-24T20:45:33.000Z", subTotal: "49.90", deliveryFee: "5.14",
    total_shipping: 5.14, total: "55.04", country: "BR", state: "São Paulo", city: "Cidade de Testes",
    district: "Vila de Testes", street: "Rua Fake de Testes", complement: "teste", latitude: -23.629037, longitude: -46.712689,
    postalCode: "85045020", number: "3454", customer: {externalCode: 136226073, name: "JOHN DOE", email: "john@doe.com",
    contact: "41999999999"}, items: [{externalCode: "IT4801901403", name: "Produto de Testes", price: 49.9, quantity: 1,
    total: 49.9,subItems: []}], payments: [{type: "CREDIT_CARD", value: 55.04}]
  }

  required_payload_fields = [
    'id', 'store_id', 'shipping.date_created', 'total_amount', 'total_shipping',
    'total_amount_with_shipping', 'shipping.receiver_address.country.id',
    'shipping.receiver_address.state.name', 'shipping.receiver_address.city.name',
    'shipping.receiver_address.neighborhood.name', 'shipping.receiver_address.street_name',
    'shipping.receiver_address.comment', 'shipping.receiver_address.latitude',
    'shipping.receiver_address.longitude', 'shipping.receiver_address.zip_code',
    'shipping.receiver_address.street_number', 'buyer.phone.number', 'buyer.phone.area_code',
    'buyer.id', 'buyer.nickname', 'buyer.email', 'order_items', 'payments'
  ]
  required_item_fields = ['item.id', 'item.title', 'unit_price', 'quantity']
  required_payment_fields = %w[payment_type total_paid_amount]

  describe '.parse' do
    context 'when all fields are present' do
      it 'returns the parsed payload' do
        parsed = described.parse(marketplace_payload)

        expect(parsed).to eq parsed_payload
      end
    end

    context 'when marketplace_payload is missing required fields' do
      # TEST REQUIRED FIELDS
      required_payload_fields.each do |field_path|
        context "when marketplace_payload.#{field_path} is missing" do
          it 'raises parsing error' do
            invalid_payload = remove_field_from_hash(marketplace_payload, field_path) # HashHelper method
            expect { described.parse(invalid_payload) }.to raise_error(CustomError::ParsingError)
          end
        end
      end

      # TEST REQUIRED ORDER_ITEMS FIELDS
      required_item_fields.each do |item_field_path|
        let(:items) { marketplace_payload['order_items'] }

        context "when marketplace_payload.#{item_field_path} is missing" do
          it 'raises parsing error' do
            item = items.first
            invalid_item = remove_field_from_hash(item, item_field_path) # HashHelper method

            invalid_payload = marketplace_payload
            invalid_payload['order_items'] = items.push(invalid_item)

            expect { described.parse(invalid_payload) }.to raise_error(CustomError::ParsingError)
          end
        end
      end

      # TEST REQUIRED PAYMENTS FIELDS
      required_payment_fields.each do |payment_field_path|
        let(:payments) { marketplace_payload['payments'] }

        context "when marketplace_payload.#{payment_field_path} is missing" do
          it 'raises parsing error' do
            payment = payments.first
            invalid_payment = remove_field_from_hash(payment, payment_field_path) # HashHelper method

            invalid_payload = marketplace_payload
            invalid_payload['payments'] = payments.push(invalid_payment)

            expect { described.parse(invalid_payload) }.to raise_error(CustomError::ParsingError)
          end
        end
      end
    end

    it 'stringifies prices using two decimal places' do
      marketplace_payload['total_amount'] = 42.4
      marketplace_payload['total_shipping'] = 42
      marketplace_payload['total_amount_with_shipping'] = 42.422222

      parsed = described.parse(marketplace_payload)
      expect(parsed[:subTotal]).to eq '42.40'
      expect(parsed[:deliveryFee]).to eq '42.00'
      expect(parsed[:total]).to eq '42.42'
    end

    it 'formats date Zulu timezone' do
      marketplace_payload['shipping']['date-created'] = '2019-06-24T16:45:33.000-04:00'
      parsed = described.parse(marketplace_payload)

      expect(parsed[:dtOrderCreate]).to eq '2019-06-24T20:45:33.000Z'
    end
  end
end
