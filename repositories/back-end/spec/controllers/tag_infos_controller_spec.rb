require 'rails_helper'

describe TagInfosController do
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
    let(:params) { { tag_info: { tag: 'xxx', description: 'YYYY' } } }
    let(:missing_name_params) { { tag_info: { tag: '' } } }

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
    let(:tag_info) { create :tag_info }
    let(:params) { { id: tag_info.id, tag_info: { description: 'some description' } } }
    let(:missing_name_params) { { id: tag_info.id, tag_info: { tag: '' } } }

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
    let(:tag_info) { create :tag_info }
    let(:params) { { id: tag_info.id } }

    it 'respond ok' do
      get :show, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :show, params: { id: 'do_not_exists' }

      expect(response).to have_http_status :not_found
    end
  end

  context '#destroy' do
    let(:tag_info) { create :tag_info }
    let(:params) { { id: tag_info.id } }

    it 'respond ok' do
      delete :destroy, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      delete :destroy, params: { id: 'do_not_exists' }

      expect(response).to have_http_status :not_found
    end
  end
end
