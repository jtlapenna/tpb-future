require 'rails_helper'

describe ReviewsController do
  let(:user) { create :user }

  before { authenticate(user) }

  context '#index' do
    before { get :index }

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#create' do
    let(:product) { create :product }
    let(:params) { { review: { text: 'xxx', reviewable_id: product.id, reviewable_type: 'Product' } } }
    let(:missing_text_params) { { review: { text: '' } } }

    it 'respond ok' do
      post :create, params: params
      expect(response).to have_http_status :created
    end

    it 'request error code' do
      post :create, params: missing_text_params

      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context '#update' do
    let(:review) { create :review }
    let(:params) { { id: review.id, review: { text: 'xxx' } } }
    let(:missing_name_params) { { id: review.id, review: { text: '' } } }

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
    let(:review) { create :review }
    let(:params) { { id: review.id } }

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
