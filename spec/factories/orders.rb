FactoryBot.define do
  factory :parsed_order, class: Hash do
    defaults = {
      externalCode: 9987071,
      storeId: 282,
      dtOrderCreate: "2019-06-24T20:45:33.000Z",
      subTotal: "49.90",
      deliveryFee: "5.14",
      total_shipping: 5.14,
      total: "55.04",
      country: "BR",
      state: "São Paulo",
      city: "Cidade de Testes",
      district: "Vila de Testes",
      street: "Rua Fake de Testes",
      complement: "teste",
      latitude: -23.629037,
      longitude: -46.712689,
      postalCode: "85045020",
      number: "3454",
      customer: {externalCode: 136226073,
        name: "JOHN DOE",
        email: "john@doe.com",
      contact: "41999999999"},
      items: [{externalCode: "IT4801901403",
        name: "Produto de Testes",
        price: 49.9,
        quantity: 1,
      total: 49.9,subItems: []}],
      payments: [{type: "CREDIT_CARD", value: 55.04}]
    }
    initialize_with{ defaults.merge(attributes) }
  end
end
