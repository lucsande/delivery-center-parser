# DeliveryCenterParser

This is a small Rails API project, with just a single endpoint: `POST /api/v1/orders`. 

It receives a JSON with data about an order from a fictional Marketplace, parses it so it is compatible with a fictional Delivery Center API, validates if all required fields are present and then sends the parsed order to the Delivery Center API. When order requests can't be processed, error logs are generated and stored in the DB, allowing further monitoring and debugging.

You can test the application by running `rails s` in your terminal and then use Postman or similar services to make requests to 'http://localhost:3000/api/v1/orders'. Make sure your requests have the header 'Content-Type: application/json' and that its body is in the following format:

```json
{
  "id": 9987071,
  "store_id": 282,
  "date_created": "2019-06-24T16:45:33.000-04:00",
  "date_closed": "2019-06-24T16:45:35.000-04:00",
  "last_updated": "2019-06-25T13:26:49.000-04:00",
  "total_amount": 49.9,
  "total_shipping": 5.14,
  "total_amount_with_shipping": 55.04,
  "paid_amount": 55.04,
  "expiration_date": "2019-07-22T16:45:35.000-04:00",
  "order_items": [
    {
      "item": {
        "id": "IT4801901403",
        "title": "Produto de Testes"
      },
      "quantity": 1,
      "unit_price": 49.9,
      "full_unit_price": 49.9
    }
  ],
  "payments": [
    {
      "id": 12312313,
      "order_id": 9987071,
      "payer_id": 414138,
      "installments": 1,
      "payment_type": "credit_card",
      "status": "paid",
      "transaction_amount": 49.9,
      "taxes_amount": 0,
      "shipping_cost": 5.14,
      "total_paid_amount": 55.04,
      "installment_amount": 55.04,
      "date_approved": "2019-06-24T16:45:35.000-04:00",
      "date_created": "2019-06-24T16:45:33.000-04:00"
    }
  ],
  "shipping": {
    "id": 43444211797,
    "shipment_type": "shipping",
    "date_created": "2019-06-24T16:45:33.000-04:00",
    "receiver_address": {
      "id": 1051695306,
      "address_line": "Rua Fake de Testes 3454",
      "street_name": "Rua Fake de Testes",
      "street_number": "3454",
      "comment": "teste",
      "zip_code": "85045020",
      "city": {
        "name": "Cidade de Testes"
      },
      "state": {
        "name": "São Paulo"
      },
      "country": {
        "id": "BR",
        "name": "Brasil"
      },
      "neighborhood": {
        "id": null,
        "name": "Vila de Testes"
      },
      "latitude": -23.629037,
      "longitude": -46.712689,
      "receiver_phone": "41999999999"
    }
  },
  "status": "paid",
  "buyer": {
    "id": 136226073,
    "nickname": "JOHN DOE",
    "email": "john@doe.com",
    "phone": {
      "area_code": 41,
      "number": "999999999"
    },
    "first_name": "John",
    "last_name": "Doe",
    "billing_info": {
      "doc_type": "CPF",
      "doc_number": "09487965477"
    }
  }
}
```

## Automated Tests
This project uses rspec as its testing framework. You can run the tests yourself by running `rails spec` on your terminal. You can explore the project's test coverage by opening the file `coverage/index.html`.


## TODO
Unfortunately, for lack of time, some things are still pending, for instance:
- validate attributes presence, uniqueness, etc in models;
- check if order already exists in DB before sending it to the Delivery Center API, so duplicates are not sent;

## Author
This project was made by Lucas Sandeville.
- [Linkedin](https://www.linkedin.com/in/lucas-coelho-sandeville-11493813b/)
- [Portfolio](https://lucas-sandeville.now.sh/)
