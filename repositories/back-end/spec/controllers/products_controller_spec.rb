require 'rails_helper'

describe ProductsController do
  let(:user) { create :user }

  before { authenticate(user) }

  context '#index' do
    before { get :index }

    it 'respond ok' do
      get :index
      expect(response).to have_http_status :ok
    end

    it 'respond ok using algolia' do
      prods = double
      allow(prods).to receive(:raw_answer).and_return('nbHits' => 3)
      allow(prods).to receive(:count).and_return 3
      allow(prods).to receive(:first).and_return(Product.all)
      expect(Product).to receive(:search).and_return(prods)

      get :index, params: { q: 'XXX' }
      expect(response).to have_http_status :ok
    end
  end

  context '#search' do
    before do
      expect(Product).not_to receive(:search)
      get :search
    end

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#create' do
    let(:category) { create :category }
    let(:params) { { product: { name: 'xxx', code: 'xxx', category_id: category.id } } }
    let(:missing_name_params) { { product: { code: 'xxx', category_id: category.id } } }

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
    let(:product) { create :product }
    let(:params) { { id: product.id, product: { name: 'xxx', code: 'xxx' } } }
    let(:missing_name_params) { { id: product.id, product: { name: '', code: 'xxx' } } }

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
    let(:product) { create :product }
    let(:params) { { id: product.id } }

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
    let(:product) { create :product }
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
