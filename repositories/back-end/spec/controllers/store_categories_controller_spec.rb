require 'rails_helper'

describe StoreCategoriesController do
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
    let(:params) { { store_id: store.id, store_category: { name: 'xxx' } } }
    let(:missing_name_params) { { store_id: store.id, store_category: { name: '' } } }

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
    let(:category) { create :store_category, store: store }
    let(:params) { { store_id: store.id, id: category.id, store_category: { name: 'xxx' } } }
    let(:missing_name_params) { { store_id: store.id, id: category.id, store_category: { name: '' } } }

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
    let(:category) { create :store_category, store: store }

    it 'respond ok' do
      get :show, params: params.merge(id: category.id)
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :show, params: params.merge(id: 'do_not_exists')

      expect(response).to have_http_status :not_found
    end
  end

  context '#destroy' do
    let(:category) { create :store_category, store: store }

    it 'respond ok' do
      delete :destroy, params: params.merge(id: category.id)

      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      delete :destroy, params: params.merge(id: 'do_not_exists')

      expect(response).to have_http_status :not_found
    end
  end
end
