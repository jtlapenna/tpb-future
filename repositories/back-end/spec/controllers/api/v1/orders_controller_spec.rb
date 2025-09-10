require 'rails_helper'

describe Api::V1::OrdersController do
  let(:kiosk) { create :kiosk, store: store }
  let(:product) { create :store_product, store: store, sku: '1234' }

  before do
    store.regenerate_jti = false
    authenticate(store)
  end

  describe 'null integration' do
    let(:store) { create :store, api_type: nil }

    describe '#create' do
      it 'respond method not allowed' do
        store.update!(api_type: nil)

        post :create, params: { catalog_id: kiosk.id }

        expect(response).to have_http_status :method_not_allowed
      end
    end
  end

  shared_examples_for 'create order integration' do
    it 'respond ok' do
      post :create, params: params

      expect(response).to have_http_status :ok
    end

    it 'respond bad request when order parameter is missing' do
      post :create, params: { catalog_id: kiosk.id }

      expect(response).to have_http_status :bad_request
    end

    it 'respond unprocessable_entity when data is not valid' do
      expect(api_mock).not_to receive(:create_order)

      post :create, params: { order: order.merge(customer_id: ''), catalog_id: kiosk.id }

      expect(response).to have_http_status :unprocessable_entity
    end

    it 'respond bad_gateway when service raise an error' do
      expect(api_mock).to receive(:create_order).with(create_params).and_raise api_error

      post :create, params: params

      expect(response).to have_http_status :bad_gateway
    end
  end

  describe 'treez integration' do
    include TreezApiHelper

    let(:store) { create :treez_store }

    context '#create' do
      let(:api_mock) { double(:treez_api_client) }
      let(:order) { treez_create_order_params(product) }
      let(:params) { { order: order, catalog_id: kiosk.id } }

      let(:create_params) { { data: to_save_order_payload(order) } }
      let(:api_error) { Treez::TreezError }

      before do
        allow(Treez::ApiClient).to receive(:new).with(store.treez_api_config).and_return(api_mock)

        allow(api_mock).to receive(:create_order).with(create_params).and_return(treez_order)

        CustomerOrder.where(customer_id: treez_order[:customer_id]).delete_all
      end

      it_behaves_like 'create order integration'

      it 'respond conflict when order already exists' do
        expect(api_mock).to receive(:create_order).with(create_params).and_raise treez_duplicate_order_error

        post :create, params: params

        expect(response).to have_http_status :conflict
      end
    end
  end

  describe 'flowhub integration' do
    include FlowhubApiHelper

    let(:store) { create :flowhub_store }

    context '#create' do
      let(:api_mock) { double(:flowhub_api_client) }
      let(:order) { flowhub_create_order_params(product) }
      let(:params) { { order: order, catalog_id: kiosk.id } }

      let(:create_params) { { data: to_save_order_payload(order).merge(externalCreatedAt: anything) } }
      let(:api_error) { Flowhub::FlowhubError }

      before do
        allow(Flowhub::ApiClient).to receive(:new).with(store.flowhub_api_config).and_return(api_mock)

        allow(api_mock).to receive(:get_customer).with(flowhub_customer[:id]).and_return(flowhub_customer)
        allow(api_mock).to receive(:create_order).with(create_params).and_return(flowhub_order)

        CustomerOrder.where(customer_id: order[:customer_id]).delete_all
      end

      it_behaves_like 'create order integration'
    end
  end

  describe 'leaflogix integration' do
    include LeaflogixApiHelper

    let(:store) { create :leaflogix_store }

    context '#create' do
      let(:api_mock) { double(:leaflogix_api_client) }
      let(:order) { leaflogix_create_order_params(product) }
      let(:params) { { order: order, catalog_id: kiosk.id } }

      let(:create_params) { { data: to_save_order_payload(order) } }
      let(:api_error) { Leaflogix::LeaflogixError }

      before do
        allow(Leaflogix::ApiClient).to receive(:new).with(store.leaflogix_api_config).and_return(api_mock)

        allow(api_mock).to receive(:get_customer).with(leaflogix_customer[:id]).and_return(leaflogix_customer)
        allow(api_mock).to receive(:create_order).with(create_params).and_return(leaflogix_order)

        CustomerOrder.where(customer_id: order[:customer_id]).delete_all
      end

      it_behaves_like 'create order integration'
    end
  end
end
