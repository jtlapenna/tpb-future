require 'rails_helper'

describe StorePricesController do
  let(:user) { create :user }
  let(:store) { create :store }
  let(:params) { { store_id: store.id } }

  before { authenticate(user) }

  context '#index' do
    before do
      get :index, params: params
    end

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#create' do
    let(:params) { { store_id: store.id, store_price: { name: 'xxx' } } }
    let(:missing_name_params) { { store_price: { name: '' } } }

    it 'respond ok' do
      post :create, params: params
      expect(response).to have_http_status :created
    end

    # it "request error code" do
    #   post :create, params: missing_name_params
    #
    #   expect(response).to have_http_status :unprocessable_entity
    # end
  end

  context '#update' do
    let(:store_price) { create :store_price, store: store }
    let(:params) { { store_id: store.id, id: store_price.id, store_price: { name: 'xxx' } } }
    let(:missing_name_params) { { id: store.id, store_price: { name: '' } } }

    it 'respond ok' do
      put :update, params: params
      expect(response).to have_http_status :ok
    end

    # it "request error code" do
    #   put :update, params: missing_name_params
    #
    #   expect(response).to have_http_status :unprocessable_entity
    # end
  end

  context '#show' do
    let(:store_price) { create :store_price, store: store }

    it 'respond ok' do
      get :show, params: params.merge(id: store_price.id)
      expect(response).to have_http_status :ok
    end

    # it "request error code" do
    #   get :show, params: { id: 'do_not_exists'}
    #
    #   expect(response).to have_http_status :not_found
    # end
  end
end
