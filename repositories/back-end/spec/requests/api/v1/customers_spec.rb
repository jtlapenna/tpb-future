require 'rails_helper'

describe 'API V1 Customers: catalog with treez integration' do
  include TreezApiHelper

  let(:store) { create :treez_store }
  let(:kiosk) { create :kiosk, store: store }
  let(:api_mock) { double(:treez_api_client) }

  before do
    allow(Treez::ApiClient).to receive(:new)
      .with(client_id: store.api_client_id, dispensary_name: store.dispensary_name, api_key: store.api_key, api_version: store.api_version).and_return api_mock
  end

  describe 'index' do
    let(:params) do
      {
        first_name: 'MAY',
        last_name: 'SMITH',
        phone: '4083522224',
        email: 'mayss@fresh.com',
        driver_license: 'N/A'
      }
    end

    it 'respond with customers' do
      expect(api_mock).to receive(:get_customers).with(filters: params).and_return(api_customer)

      get api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'customers'
      expect(json['customers']).to eq customer_response
    end

    it "respond with message when catalog don't have api type" do
      store.update!(api_type: nil)

      get api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq "catalog doesn't support this operation"
    end

    it 'respond with message when treez raise an unexpected error' do
      expect(api_mock).to receive(:get_customers).with(filters: params).and_raise Treez::TreezError.new('Some error')

      get api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq 'unexpected error respone from the API. Detail: Some error'
    end

    def api_customer
      [treez_customer]
    end

    def customer_response
      [to_peak_customer(treez_customer)].as_json
    end
  end

  describe 'create' do
    let(:customer_params) { treez_create_customer_params }
    let(:params) { { customer: customer_params.merge(other: 'value'), catalog_id: kiosk.id } }
    let(:create_customer_params) { { data: customer_params } }

    it 'respond with created customer' do
      expect(api_mock).to receive(:create_customer).with(create_customer_params).and_return(treez_customer)

      post api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'customer'
      expect(json['customer']).to eq customer_response
    end

    it "respond with message when catalog don't have api type" do
      store.update!(api_type: nil)

      post api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq "catalog doesn't support this operation"
    end

    it 'respond with missing parameter' do
      expect(api_mock).not_to receive(:create_customer)

      post api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: {}

      expect(json).to have_key 'message'
      expect(json['message']).to eq 'param is missing or the value is empty: customer'
    end

    it 'respond with conflict when customer is duplicate' do
      expect(api_mock).to receive(:create_customer).and_raise(treez_duplicate_customer_error)

      post api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq 'customer already exists'
    end

    it 'respond with errors when data is not valid' do
      params = { customer: customer_params.merge(first_name: nil, last_name: nil, phone: nil, email: nil, birthday: '2018-02-30') }

      expect(api_mock).not_to receive(:create_customer)

      post api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expected_errors = {
        'birthday' => ['is not a valid date'],
        'email' => ["can't be blank"],
        'first_name' => ["can't be blank"],
        'last_name' => ["can't be blank"],
        'phone' => ["can't be blank"]
      }

      expect(json).to have_key 'errors'
      expect(json['errors']).to eq expected_errors
    end

    it 'respond with message when treez raise an unexpected error' do
      expect(api_mock).to receive(:create_customer).with(create_customer_params).and_raise Treez::TreezError.new('Some error')

      post api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq 'unexpected error respone from the API. Detail: Some error'
    end

    def customer_response
      to_peak_customer(treez_customer).as_json
    end
  end
end

describe 'API V1 Customers: catalog with flowhub integration' do
  include FlowhubApiHelper

  let(:store) { create :flowhub_store }
  let(:kiosk) { create :kiosk, store: store }
  let(:api_mock) { double(:flowhub_api_client) }

  before do
    api_config = {
      client_id: store.api_client_id, location_id: store.location_id, api_key: store.api_key,
      auth0_client_id: store.auth0_client_id, auth0_client_secret: store.auth0_client_secret
    }
    allow(Flowhub::ApiClient).to receive(:new).with(api_config).and_return api_mock
  end

  describe 'index' do
    let(:params) do
      {
        first_name: 'MAY',
        last_name: 'SMITH',
        phone: '4083522224',
        email: 'mayss@fresh.com',
        driver_license: 'N/A'
      }
    end

    it 'respond with customers' do
      expect(api_mock).to receive(:get_customers).with(filters: params).and_return(api_customer)

      get api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'customers'
      expect(json['customers']).to eq customer_response
    end

    it "respond with message when catalog don't have api type" do
      store.update!(api_type: nil)

      get api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq "catalog doesn't support this operation"
    end

    it 'respond with message when flowhub raise an unexpected error' do
      expect(api_mock).to receive(:get_customers).with(filters: params).and_raise Flowhub::FlowhubError.new('Some error')

      get api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq 'unexpected error respone from the API. Detail: Some error'
    end

    def api_customer
      [flowhub_customer]
    end

    def customer_response
      [to_peak_customer(flowhub_customer)].as_json
    end
  end

  describe 'create' do
    let(:customer_params) { treez_create_customer_params }
    let(:params) { { catalog_id: kiosk.id } }
    let(:create_customer_params) { { data: customer_params } }

    it 'respond with message' do
      post api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq "catalog doesn't support this operation"
    end
  end
end

describe 'API V1 Customers: catalog with leaflogix integration' do
  include LeaflogixApiHelper

  let(:store) { create :leaflogix_store }
  let(:kiosk) { create :kiosk, store: store }
  let(:customer_client) { instance_double(Leaflogix::CustomerClient) }
  let(:customer) { create :customer, first_name: 'Mark', last_name: 'wesley', status: 'active', phone: '1234', email: 'customer1@email.com', drivers_license: '123' }

  before do
    allow(Leaflogix::CustomerClient).to receive(:new)
      .with(store.id, api_key: store.api_key).and_return customer_client

    customer # initialize
  end

  describe 'index' do
    let(:params) do
      {
        first_name: 'Mark',
        last_name: 'wesley',
        phone: '1234',
        email: 'customer1@email.com',
        driver_license: '123'
      }
    end

    it 'respond with customers' do
      expect(customer_client).to receive(:all).with(params).and_return([customer.to_peak_customer])

      get api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'customers'
      expect(json['customers']).to eq customer_response
    end

    it "respond with message when catalog don't have api type" do
      store.update!(api_type: nil)

      get api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq "catalog doesn't support this operation"
    end

    def customer_response
      [customer.to_peak_customer].as_json
    end
  end

  describe 'create' do
    let(:customer_params) { treez_create_customer_params }
    let(:params) { { catalog_id: kiosk.id } }
    let(:create_customer_params) { { data: customer_params } }

    it 'respond with message' do
      post api_v1_catalogs_customers_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to have_key 'message'
      expect(json['message']).to eq "catalog doesn't support this operation"
    end
  end
end
