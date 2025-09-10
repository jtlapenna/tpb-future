require 'rails_helper'

describe Api::V1::CustomersController do
  let(:kiosk) { create :kiosk, store: store }

  before do
    store.regenerate_jti = false
    authenticate(store)
  end

  describe 'null integration' do
    let(:store) { create :store, api_type: nil }

    context '#index' do
      it "respond method not allowed when catalog don't have api type" do
        store.update!(api_type: nil)

        get :index, params: { catalog_id: kiosk.id }

        expect(response).to have_http_status :method_not_allowed
      end
    end

    context '#create' do
      it "respond method not allowed when store don't have api type" do
        store.update!(api_type: nil)

        post :create, params: { catalog_id: kiosk.id }

        expect(response).to have_http_status :method_not_allowed
      end
    end
  end

  describe 'treez integration' do
    include TreezApiHelper

    let(:store) { create :treez_store }

    context '#index' do
      it 'respond ok' do
        get :index, params: { catalog_id: kiosk.id }

        expect(response).to have_http_status :ok
      end
    end

    context '#create' do
      let(:api_mock) { double(:treez_api_client) }
      let(:params) { { customer: treez_create_customer_params, catalog_id: kiosk.id } }
      let(:create_params) { { data: treez_create_customer_params } }

      before do
        allow(Treez::ApiClient).to receive(:new)
          .with(store.treez_api_config).and_return api_mock

        allow(api_mock).to receive(:create_customer).with(create_params).and_return(treez_customer)
      end

      it 'respond ok' do
        post :create, params: params

        expect(response).to have_http_status :created
      end

      it 'respond bad request when customer parameter is missing' do
        post :create, params: { catalog_id: kiosk.id }

        expect(response).to have_http_status :bad_request
      end

      it 'respond conflict when customer already exists' do
        expect(api_mock).to receive(:create_customer).with(create_params).and_raise treez_duplicate_customer_error

        post :create, params: params

        expect(response).to have_http_status :conflict
      end

      it 'respond unprocessable_entity when data is not valid' do
        expect(api_mock).not_to receive(:create_customer)

        post :create, params: {
          customer: treez_create_customer_params.merge(first_name: ''),
          catalog_id: kiosk.id
        }

        expect(response).to have_http_status :unprocessable_entity
      end

      it 'respond bad_gateway when treez raise an error' do
        expect(api_mock).to receive(:create_customer).with(create_params).and_raise Treez::TreezError

        post :create, params: { customer: treez_create_customer_params, catalog_id: kiosk.id }

        expect(response).to have_http_status :bad_gateway
      end
    end
  end

  describe 'flowhub integration' do
    include FlowhubApiHelper

    let(:store) { create :flowhub_store }

    context '#index' do
      it 'respond ok' do
        get :index, params: { catalog_id: kiosk.id }

        expect(response).to have_http_status :ok
      end
    end

    context '#create' do
      it "respond method not allowed when store don't have api type" do
        post :create, params: { catalog_id: kiosk.id }

        expect(response).to have_http_status :method_not_allowed
      end
    end
  end

  describe 'leaflogix integration' do
    include LeaflogixApiHelper

    let(:store) { create :leaflogix_store }

    context '#index' do
      it 'respond ok' do
        get :index, params: { catalog_id: kiosk.id }

        expect(response).to have_http_status :ok
      end
    end

    context '#create' do
      it 'respond method not allowed' do
        post :create, params: { catalog_id: kiosk.id }

        expect(response).to have_http_status :method_not_allowed
      end
    end
  end
end
