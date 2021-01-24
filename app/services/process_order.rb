require 'parser/marketplace_to_delivery_center/order_payload'
require 'delivery_center/api'

# service for parsing orders from the marketplace, send it to Delivery Center and store relevant data in DB
class ProcessOrder
  class << self
    # ProcessOrder strongly coupled with Parser::MarketplaceToDeliveyCenter::Order
    # but while we have integrations with only one Marketplace, it's ok
    def call(order_payload)
      parsed_order = Parser::MarketplaceToDeliveryCenter::OrderPayload.parse(order_payload)
      DeliveryCenter::Api.place_order(parsed_order)

      create_records(order_payload, parsed_order)
      parsed_order
    rescue ParsingError, DeliveryCenter::ApiError => e
      FailedOrderLog.create(received_order_json: order_payload.to_json, error_message: e.message)
      raise e
    end

    private

    def create_records(order_payload, parsed_order)
      ActiveRecord::Base.transaction do
        store = find_or_create_store(parsed_order)
        products = find_or_create_products(parsed_order)
        payments = find_or_create_payments(parsed_order)
        customer = find_or_create_customer(parsed_order)
        find_or_create_order(order_payload, parsed_order, store, products, payments, customer)
      end
    end

    def find_or_create_store(parsed_order)
      Store.find_or_create_by(marketplace_id: parsed_order[:storeId])
    end

    def find_or_create_products(parsed_order)
      products = []
      parsed_order[:items].each do |item|
        product = Product.create_with(name: item[:name], price: item[:price])
                         .find_or_create_by(marketplace_id: item[:externalCode])

        products.push(product)
      end
      products
    end

    def find_or_create_payments(parsed_order)
      payments = []
      parsed_order[:payments].each do |order_payment|
        payment_type = PaymentType.find_or_create_by(name: order_payment[:type])
        payment = Payment.create(value: order_payment[:value], payment_type_id: payment_type.id)
        payments.push(payment)
      end
      payments
    end

    def find_or_create_customer(parsed_order)
      customer = parsed_order[:customer]
      Customer.create_with(email: customer[:email], contact: customer[:contact])
              .find_or_create_by(marketplace_id: customer[:externalCode])
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def find_or_create_order(order_payload, parsed_order, store, products, payments, customer)
      product_quantity = 0
      parsed_order[:items].each { |item| product_quantity += item[:quantity] }

      order = Order.new({
                          store: store,
                          customer: customer,
                          marketplace_id: parsed_order[:externalCode],
                          subtotal: parsed_order[:subtotal],
                          delivery_fee: parsed_order[:deliveryFee],
                          total_shipping: parsed_order[:total_shipping],
                          total: parsed_order[:total],
                          country: parsed_order[:country],
                          state: parsed_order[:state],
                          city: parsed_order[:city],
                          district: parsed_order[:district],
                          street: parsed_order[:street],
                          complement: parsed_order[:complement],
                          latitude: parsed_order[:latitude],
                          longitude: parsed_order[:longitude],
                          marketplace_creation_date: parsed_order[:dtOrderCreate],
                          postal_code: parsed_order[:postalCode],
                          address_number: parsed_order[:number],
                          product_quantity: product_quantity,
                          marketplace_order_payload: order_payload.to_json,
                          processed_by_delivery_center: true
                        })
      products.each { |p| OrdersProduct.create(order: order, product: p) }
      payments.each { |p| OrdersPayment.create(order: order, payment: p) }

      order.save
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
