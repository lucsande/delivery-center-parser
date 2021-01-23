# parses data
module Parser
  # parses data from Marketplace format to DeliveryCenter format
  module MarketplaceToDeliveryCenter
    # parses order payloads received from the Marketplace
    class OrderPayload
      class << self
        def parse(marketplace_payload)
          parsed_hashes = [
            general_data(marketplace_payload),
            pricing_data(marketplace_payload),
            address_data(marketplace_payload),
            customer_data(marketplace_payload),
            items_data(marketplace_payload),
            payments_data(marketplace_payload)
          ]

          parsed_order = parsed_hashes.inject(:merge) # merges array of hashes into single hash
          validate_order_fields(parsed_order)

          parsed_order
        end

        private

        def stringify_price(price)
          return nil if price.nil?

          format('%<price>.2f', price: price.to_f)
        end

        def parse_datetime(date_str)
          return nil if date_str.nil?

          dt = date_str.to_datetime.utc
          dt.strftime('%FT%T.%LZ')
        end

        def general_data(marketplace_payload)
          creation_date = marketplace_payload.dig('shipping', 'date_created')

          {
            externalCode: marketplace_payload['id'],
            storeId: marketplace_payload['store_id'],
            dtOrderCreate: parse_datetime(creation_date)
          }
        end

        def pricing_data(marketplace_payload)
          {
            subTotal: stringify_price(marketplace_payload['total_amount']),
            deliveryFee: stringify_price(marketplace_payload['total_shipping']),
            total_shipping: marketplace_payload['total_shipping'],
            total: stringify_price(marketplace_payload['total_amount_with_shipping'])
          }
        end

        # rubocop:disable Metrics/MethodLength
        def address_data(marketplace_payload)
          receiver_address = marketplace_payload.dig('shipping', 'receiver_address') || {}

          {
            country: receiver_address.dig('country', 'id'),
            state: receiver_address.dig('state', 'name'),
            city: receiver_address.dig('city', 'name'),
            district: receiver_address.dig('neighborhood', 'name'),
            street: receiver_address['street_name'],
            complement: receiver_address['comment'],
            latitude: receiver_address['latitude'],
            longitude: receiver_address['longitude'],
            postalCode: receiver_address['zip_code'],
            number: receiver_address['street_number']
          }
        end
        # rubocop:enable Metrics/MethodLength

        def customer_data(marketplace_payload)
          buyer = marketplace_payload['buyer'] || {}
          phone = buyer['phone'] || {}
          contact = phone['area_code'] && phone['number'] ? phone['area_code'].to_s + phone['number'] : nil
          {
            customer: {
              externalCode: buyer['id'],
              name: buyer['nickname'],
              email: buyer['email'],
              contact: contact
            }
          }
        end

        def items_data(marketplace_payload)
          return { items: nil } unless marketplace_payload['order_items']

          parsed_items = marketplace_payload['order_items'].map do |item|
            total = item['quantity'] && item['unit_price'] ? item['quantity'] * item['unit_price'] : nil

            {
              externalCode: item.dig('item', 'id'),
              name: item.dig('item', 'title'),
              price: item['unit_price'],
              quantity: item['quantity'],
              total: total,
              subItems: []
            }
          end

          { items: parsed_items }
        end

        def payments_data(marketplace_payload)
          return { payments: nil } unless marketplace_payload['payments']

          parsed_payments = marketplace_payload['payments'].map do |payment|
            marketplace_payment_type = payment['payment_type']
            delivery_center_payment_type = payment_types_dict[marketplace_payment_type]

            {
              type: delivery_center_payment_type,
              value: payment['total_paid_amount']
            }
          end

          { payments: parsed_payments }
        end

        def payment_types_dict
          { 'credit_card' => 'CREDIT_CARD' }
        end

        # if order has any field with value of nil, it raises an error, since all fields are required
        def validate_order_fields(order_data)
          order_data.each do |key, value|
            validate_order_fields(value) if value.is_a?(Hash)
            value.each { |item| validate_order_fields(item) } if value.is_a?(Array)

            raise CustomError::ParsingError, "A required field with information about #{key} was missing" if value.nil?
          end
        end
      end
    end
  end
end
