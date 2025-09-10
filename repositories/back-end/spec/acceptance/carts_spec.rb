require 'acceptance_helper'

resource 'Carts', type: :request do
  let(:store) { create :store }
  let(:kiosk) { create :kiosk, store: store }
  let(:category) { create :store_category, store: store }
  let(:product) { create :store_product, store_category: category, weight: 2 }
  let(:api_key) { auth_token(store) }
  let(:catalog_id) { kiosk.id }

  explanation 'Cart resources'

  authentication :apiKey, :api_key, description: 'Private key for API access', name: 'Authorization'
  header 'Content-Type', 'application/json'
  header 'Accept', 'application/json'

  post '/api/v1/:catalog_id/carts/validate' do
    let(:params) { { cart: { items: [{ product_id: product.id, quantity: 2 }] } } }

    route_summary 'Validate cart'

    items = {
      type: :object,
      properties: {
        product_id: { type: :string, required: true, example: '444' },
        quantity: { type: :integer, required: true, example: 2 }
      }
    }

    with_options scope: :cart, with_example: true do
      parameter :items, type: :array, items: items
    end

    context '200' do
      example 'invalid a cart' do
        store.settings.purchase_limits.create!(limit: 1, store_categories: [category])

        do_request

        expect(status).to eq 200
        expect(json).to include({ success: false }.as_json)
      end
    end
  end
end
