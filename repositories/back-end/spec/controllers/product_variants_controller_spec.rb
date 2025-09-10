require 'rails_helper'

describe ProductVariantsController do
  let(:user) { create :user }

  before { authenticate(user) }

  context '#index' do
    before do
      get :index
    end

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end

    it 'respond ok using algolia' do
      prods = double
      allow(prods).to receive(:raw_answer).and_return('nbHits' => 3)
      allow(prods).to receive(:count).and_return 3
      allow(prods).to receive(:first).and_return(ProductVariant.all)
      expect(ProductVariant).to receive(:search).and_return(prods)

      get :index, params: { q: 'XXX' }
      expect(response).to have_http_status :ok
    end
  end

  context '#create' do
    let(:product) { create :product }
    let(:params) { { product_variant: { name: 'xxx', product_id: product.id, sku: '123' } } }
    let(:missing_prod_params) { { product_variant: { name: 'name' } } }

    it 'respond ok' do
      post :create, params: params
      expect(response).to have_http_status :created
    end

    it 'request error code' do
      post :create, params: missing_prod_params

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#update' do
    let(:product) { create :product }
    let(:product_variant) { create :product_variant }
    let(:params) { { id: product_variant.id, product_variant: { name: 'xxx', product_id: product.id } } }
    let(:missing_prod_params) { { id: product_variant.id, product_variant: { name: 'name', product_id: '' } } }

    it 'respond ok' do
      put :update, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      put :update, params: missing_prod_params

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#show' do
    let(:product) { create :product }
    let(:product_variant) { create :product_variant, product: product }
    let(:params) { { id: product_variant.id } }

    it 'respond ok' do
      get :show, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :show, params: { id: 'do_not_exists' }

      expect(response).to have_http_status :not_found
    end
  end

  context '#tags' do
    let(:product) { create :product_variant }
    let(:params) { { id: product.id } }

    it 'respond ok' do
      get :tags, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :tags, params: { id: 'do_not_exists' }

      expect(response).to have_http_status :not_found
    end
  end
end
