require 'acceptance_helper'

resource 'Catalog articles', type: :request do
  let(:kiosk) { create :kiosk }
  let(:api_key) { auth_token(kiosk.store) }

  explanation 'Catalog articles resources'

  authentication :apiKey, :api_key, description: 'Private key for API access', name: 'Authorization'
  header 'Content-Type', 'application/json'

  get '/api/v1/:catalog_id/articles' do
    let(:catalog_id) { kiosk.id }
    let!(:catalog_articles) { create_list :store_article, 3, store: kiosk.store }

    sortable_api_parameters
    pageable_api_parameters

    route_summary 'Get all catalog articles'

    context '200' do
      example_request 'get catalog articles' do
        expect(status).to eq 200

        expect(json).to have_key 'articles'
        expect(json['articles'].count).to eq 3
      end
    end
  end
end
