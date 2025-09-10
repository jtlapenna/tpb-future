require 'rails_helper'

describe ArticlesController do
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
    let(:params) { { article: { title: 'xxx', text: 'text', tag: 'tag' } } }
    let(:missing_title_params) { { article: { text: 'text', tag: 'tag' } } }

    it 'respond ok' do
      post :create, params: params

      expect(response).to have_http_status :created
    end

    it 'request error code' do
      post :create, params: missing_title_params

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#update' do
    let(:article) { create :article }
    let(:params) { { id: article.id, article: { title: 'xxx', text: 'text', tag: 'tag' } } }
    let(:missing_title_params) { { id: article.id, article: { title: '', text: 'text', tag: 'tag' } } }

    it 'respond ok' do
      put :update, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      put :update, params: missing_title_params

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#show' do
    let(:article) { create :article }
    let(:params) { { id: article.id } }

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
