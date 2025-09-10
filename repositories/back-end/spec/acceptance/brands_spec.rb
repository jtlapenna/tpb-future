require 'acceptance_helper'

resource 'Brands', type: :request do
  let(:store) { create :store }
  let(:kiosk) { create :kiosk, store: store }
  let(:api_key) { auth_token(kiosk.store) }

  explanation 'Brands resources'

  authentication :apiKey, :api_key, description: 'Private key for API access', name: 'Authorization'
  header 'Content-Type', 'application/json'

  get '/api/v1/:catalog_id/brands' do
    let(:catalog_id) { kiosk.id }
    let(:brands) { create_list :brand, 3 }

    sortable_api_parameters
    pageable_api_parameters

    route_summary 'Get all brands on catalog'

    before do
      create :kiosk_product, kiosk: kiosk,
                             store_product: create(:store_product, store: store, product_variant: create(:product_variant, brand: brands[0]), stock: 2)
      create :kiosk_product, kiosk: kiosk,
                             store_product: create(:store_product, store: store, product_variant: create(:product_variant, brand: brands[1]), stock: 54)
      create :kiosk_product, kiosk: kiosk,
                             store_product: create(:store_product, store: store, product_variant: create(:product_variant, brand: brands[2]), stock: 1)
    end

    context '200' do
      example_request 'get brands' do
        expect(status).to eq 200

        expect(json).to have_key 'brands'
        expect(json['brands'].count).to eq 3
      end
    end
  end
end
