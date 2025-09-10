require 'acceptance_helper'

resource 'Stores', type: :request do
  let!(:bg_media) { create :asset, source: settings }
  let!(:settings) { create :store_setting, data: settings_attributes, store: store }
  let(:store) { create :store }
  let(:kiosk) { create :kiosk, store: store }
  let(:api_key) { auth_token(kiosk.store) }

  let(:settings_attributes) do
    {
      admin_email: 'admin@admin.org',
      printer_location: 'printer location',
      pos_location: 'pos location',
      main_color: '#502424',
      secondary_color: '#502424',
      featured_products_on_top_for_brands_page: false,
      featured_products_on_top_for_effects_and_uses_page: true,
      featured_products_on_top_for_products_page: true,
      idle_delay: 10,
      restart_delay: 5,
      service_worker_log: false,
      default_product_description: 'description',
      heap_id: 'ABC1',
      dispensary_license_number: '123',
      disable_tax_message: true
    }
  end

  explanation 'Store resources'

  authentication :apiKey, :api_key, description: 'Private key for API access', name: 'Authorization'
  header 'Content-Type', 'application/json'

  get '/api/v1/stores' do
    route_summary 'Get store details'

    context '200' do
      example_request 'get store details' do
        expect(status).to eq 200
      end
    end
  end

  get '/api/v1/stores/show' do
    route_summary 'Get store details'

    context '200' do
      example_request 'get store details' do
        expect(status).to eq 200
      end
    end
  end
end
