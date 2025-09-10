require 'rails_helper'

describe StoresController do
  let(:user) { create :user }

  before { authenticate(user) }

  context '#index' do
    before do
      get :index
    end

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#create' do
    let(:client) { create :client }
    let(:params) { { store: { name: 'xxx', client_id: client.id } } }
    let(:missing_name_params) { { store: { active: false } } }

    it 'respond ok' do
      post :create, params: params
      expect(response).to have_http_status :created
    end

    it 'request error code' do
      post :create, params: missing_name_params

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#update' do
    let(:store) { create :store }
    let(:params) { { id: store.id, store: { name: 'xxx' } } }
    let(:missing_name_params) { { id: store.id, store: { name: '' } } }

    it 'respond ok' do
      put :update, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      put :update, params: missing_name_params

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#show' do
    let(:store) { create :store }
    let(:params) { { id: store.id } }

    it 'respond ok' do
      get :show, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :show, params: { id: 'do_not_exists' }

      expect(response).to have_http_status :not_found
    end
  end

  context '#token' do
    let(:store) { create :store }

    it 'respond ok with valid creadentials' do
      post :generate_token, params: { id: store.id }

      expect(response).to have_http_status :created
    end
  end
end
