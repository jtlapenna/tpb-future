require 'rails_helper'

describe StoreArticlesController do
  let(:user) { create :user }
  let(:store) { create :store }

  before { authenticate(user) }

  context '#index' do
    before do
      get :index, params: { store_id: store.id }
    end

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#show' do
    let(:store) { article.store }
    let(:article) { create :store_article }
    let(:params) { { store_id: store.id, id: article.id } }

    it 'respond ok' do
      get :show, params: params

      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :show, params: { store_id: store.id, id: 'do_not_exists' }

      expect(response).to have_http_status :not_found
    end
  end

  context '#create' do
    let(:store) { create :store }
    let(:article) { create :article }
    let(:params) { { store_id: store.id, article: { article_id: article.id } } }
    let(:missing_name_params) { { store_id: store.id, article: { store_id: store.id } } }

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
    let(:store) { article.store }
    let(:article) { create :store_article }
    let(:params) { { store_id: store.id, id: article.id, article: { id: article.id } } }

    it 'respond ok' do
      put :update, params: params
      expect(response).to have_http_status :ok
    end
  end

  context '#destroy' do
    let(:store) { article.store }
    let(:article) { create :store_article }
    let(:params) { { store_id: store.id, id: article.id } }

    it 'respond ok' do
      delete :destroy, params: params

      expect(response).to have_http_status :no_content
    end

    it 'respond 404 when article not found' do
      delete :destroy, params: params.merge(id: 'not_exist')

      expect(response).to have_http_status :not_found
    end

    it 'respond with error' do
      articles = double
      d_store = double(store_articles: articles)

      expect(articles).to receive(:find).and_return(article)
      expect(Store).to receive(:find).and_return(d_store)
      expect(article).to receive(:destroy).and_return false

      delete :destroy, params: params

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#default_products' do
    let(:store) { article.store }
    let(:article) { create :store_article }
    let(:params) { { store_id: store.id, article_id: article.article_id } }

    it 'respond ok' do
      get :default_products, params: params

      expect(response).to have_http_status :ok
    end

    it 'respond 404 when article_id is missing' do
      get :default_products, params: params.except(:article_id)

      expect(response).to have_http_status :not_found
    end

    it 'respond 404 when article_id does not exists' do
      get :default_products, params: params.merge(article_id: -1)

      expect(response).to have_http_status :not_found
    end
  end
end
