require 'rails_helper'

describe KiosksController do
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
    let(:store) { create :store }
    let(:params) { { kiosk: { name: 'xxx', store_id: store.id } } }
    let(:missing_name_params) { { kiosk: { name: '' } } }

    it 'respond ok' do
      post :create, params: params
      expect(response).to have_http_status :created
    end

    it 'request error code' do
      post :create, params: missing_name_params

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#clone' do
    let(:kiosk) { create :kiosk }
    let(:params) { { id: kiosk.id } }
    let(:no_match_id_param) { { id: 'xxx' } }

    it 'respond ok' do
      post :clone, params: params
      expect(response).to have_http_status :created
    end

    it 'request error code' do
      post :clone, params: no_match_id_param

      expect(response).to have_http_status :not_found
    end
  end

  context '#update' do
    let(:kiosk) { create :kiosk }
    let(:params) { { id: kiosk.id, kiosk: { name: 'xxx' } } }
    let(:missing_name_params) { { id: kiosk.id, kiosk: { name: '' } } }

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
    let(:kiosk) { create :kiosk }
    let(:params) { { id: kiosk.id } }

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
