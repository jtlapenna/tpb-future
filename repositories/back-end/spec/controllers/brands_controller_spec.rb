require 'rails_helper'

describe BrandsController do
  let(:user) { create :user }

  before { authenticate(user) }

  context '#index' do
    before do
      get :index
    end

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end

    context 'as client' do
      let(:user) { create :user, client: create(:client) }

      it 'respond ok' do
        expect(response).to have_http_status :ok
      end
    end
  end

  context '#create' do
    let(:params) { { brand: { name: 'xxx' } } }
    let(:missing_name_params) { { brand: { name: '' } } }

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
    let(:brand) { create :brand }
    let(:params) { { id: brand.id, brand: { name: 'xxx' } } }
    let(:missing_name_params) { { id: brand.id, brand: { name: '' } } }

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
    let(:brand) { create :brand }
    let(:params) { { id: brand.id } }

    it 'respond ok' do
      get :show, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :show, params: { id: 'do_not_exists' }

      expect(response).to have_http_status :not_found
    end
  end
end
