require 'acceptance_helper'

resource 'Categories', type: :request do
  let(:store) { create :store, categories_count: 3 }
  let(:kiosk) { create :kiosk, store: store }
  let(:api_key) { auth_token(kiosk.store) }

  explanation 'Catalogs resource'

  authentication :apiKey, :api_key, description: 'Private key for API access', name: 'Authorization'
  header 'Content-Type', 'application/json'

  get '/api/v1/:catalog_id/categories' do
    let(:catalog_id) { kiosk.id }

    route_summary 'Get catalog categories'

    context '200' do
      before do
        store.store_categories.each { |sc| create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store_category: sc) }
      end

      example_request 'get catalog categories' do
        expect(status).to eq 200

        expect(json).to have_key 'categories'
        expect(json['categories'].count).to eq 3
      end
    end
  end
end
