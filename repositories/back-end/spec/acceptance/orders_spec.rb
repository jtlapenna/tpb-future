require 'acceptance_helper'

resource 'Orders', type: :request do
  include TreezApiHelper

  let(:store) { create :treez_store }
  let(:kiosk) { create :kiosk, store: store }
  let(:api_key) { auth_token(store) }
  let(:api_mock) { double(:treez_api_client) }
  let(:product) { create :store_product, store: store, sku: 'some-sku' }

  explanation 'Order resources'

  authentication :apiKey, :api_key, description: 'Private key for API access', name: 'Authorization'
  header 'Content-Type', 'application/json'
  header 'Accept', 'application/json'

  post '/api/v1/:catalog_id/orders' do
    let(:catalog_id) { kiosk.id }
    let(:order_params) { treez_create_order_params(product) }
    let(:params) { { order: order_params.merge(other: 'value') } }
    let(:create_order_params) { { data: to_save_order_payload(order_params) } }

    route_summary 'Create an order'

    items = {
      type: :object,
      properties: {
        product_id: { type: :string, required: true, example: '444' },
        quantity: { type: :integer, required: true, example: 2 },
        product_value_id: { type: :number, example: 1, require: false }
      }
    }

    with_options scope: :order, with_example: true do
      parameter :customer_id, 'The customer id'
      parameter :customer_name, 'The customer name'
      parameter :customer_email, 'The customer email'
      parameter :items, type: :array, items: items
    end

    before do
      allow(Treez::ApiClient).to receive(:new).with(store.treez_api_config).and_return api_mock
      expect(api_mock).to receive(:create_order).with(create_order_params).and_return(treez_order)
    end

    context '201' do
      example_request 'create order' do
        expect(status).to eq 200
        expect(json).to have_key 'order'
      end
    end
  end
end
