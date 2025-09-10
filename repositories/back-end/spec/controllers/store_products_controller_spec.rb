require 'rails_helper'

describe StoreProductsController do
  let(:user) { create :user }

  before { authenticate(user) }

  context '#index' do
    let(:store) { create :store }

    it 'respond ok' do
      get :index, params: { store_id: store.id }

      expect(response).to have_http_status :ok
    end

    it 'respond ok using algolia' do
      prods = double
      allow(prods).to receive(:raw_answer).and_return('nbHits' => 3)
      allow(prods).to receive(:count).and_return 3
      allow(prods).to receive(:first).and_return(StoreProduct.all)
      expect(StoreProduct).to receive(:search).and_return(prods)

      get :index, params: { store_id: store.id, q: 'XXX' }
      expect(response).to have_http_status :ok
    end
  end

  context '#search' do
    let(:store) { create :store }

    before { get :search, params: { store_id: store.id } }

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#create' do
    let(:variant) { create :product_variant }
    let(:category) { create :store_category }
    let(:params) { { store_product: { sku: '12345678', name: 'xxx', store_category_id: category.id, product_variant_id: variant.id } } }
    let(:missing_name_params) { { store_product: { store_category_id: category.id } } }

    it 'respond ok' do
      post :create, params: params.merge(store_id: category.store_id)
      expect(response).to have_http_status :created
    end

    it 'request error code' do
      post :create, params: missing_name_params.merge(store_id: category.store_id)

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#update' do
    let(:variant) { product.product_variant }
    let(:product) { create :store_product }
    let(:params) { { id: product.id, store_id: product.store_id, store_product: { name: 'xxx', product_variant_id: variant.id } } }

    it 'respond ok' do
      put :update, params: params
      expect(response).to have_http_status :ok
    end
  end

  context '#show' do
    let(:product) { create :store_product }
    let(:params) { { id: product.id, store_id: product.store_id } }

    it 'respond ok' do
      get :show, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :show, params: { id: 'do_not_exists', store_id: product.store_id }

      expect(response).to have_http_status :not_found
    end
  end

  context '#destroy' do
    let(:product) { create :store_product }
    let(:params) { { id: product.id, store_id: product.store_id } }

    it 'respond ok' do
      delete :destroy, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      delete :destroy, params: { id: 'do_not_exists', store_id: product.store_id }

      expect(response).to have_http_status :not_found
    end
  end
end
