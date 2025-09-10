require 'acceptance_helper'

resource 'Customers', type: :request do
  include TreezApiHelper

  let(:store) { create :treez_store }
  let(:kiosk) { create :kiosk, store: store }
  let(:api_key) { auth_token(store) }
  let(:api_mock) { double(:treez_api_client) }

  explanation 'Customer resources'

  authentication :apiKey, :api_key, description: 'Private key for API access', name: 'Authorization'
  header 'Content-Type', 'application/json'

  get '/api/v1/:catalog_id/customers' do
    let(:catalog_id) { kiosk.id }
    let(:params) do
      {
        first_name: 'MAY',
        last_name: 'SMITH',
        phone: '4083522224',
        email: 'mayss@fresh.com',
        driver_license: 'N/A'
      }
    end

    route_summary 'Get customers'

    before do
      allow(Treez::ApiClient).to receive(:new)
        .with(client_id: store.api_client_id, dispensary_name: store.dispensary_name, api_key: store.api_key, api_version: store.api_version).and_return api_mock

      expect(api_mock).to receive(:get_customers).with(filters: params).and_return([treez_customer])
    end

    context '200' do
      example_request 'get customers' do
        expect(status).to eq 200

        expect(json).to have_key 'customers'
        expect(json['customers'].count).to eq 1
      end
    end
  end

  post '/api/v1/:catalog_id/customers' do
    let(:catalog_id) { kiosk.id }
    let(:customer_params) { treez_create_customer_params }
    let(:create_customer_params) { { data: customer_params } }
    let(:raw_post) { { customer: customer_params.merge(other: 'value') }.to_json }

    route_summary 'Create customer'

    with_options scope: :customer, with_example: true do
      parameter :first_name
      parameter :last_name
      parameter :gender
      parameter :birthday
      parameter :email
      parameter :phone
      parameter :drivers_license
      parameter :notes
    end

    before do
      allow(Treez::ApiClient).to receive(:new)
        .with(client_id: store.api_client_id, dispensary_name: store.dispensary_name, api_key: store.api_key, api_version: store.api_version).and_return api_mock
      expect(api_mock).to receive(:create_customer).with(create_customer_params).and_return(treez_customer)
    end

    context '200' do
      example_request 'create customer' do
        expect(status).to eq 201

        expect(json).to have_key 'customer'
      end
    end
  end
end
