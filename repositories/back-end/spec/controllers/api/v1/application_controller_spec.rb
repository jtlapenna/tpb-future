require 'rails_helper'

describe Api::V1::ApplicationController do
  let(:store) { create :store }
  let(:user) { create :user }

  controller do
    def index
      head :ok
    end
  end

  it 'is not authorized' do
    get :index

    expect(response).to have_http_status(:unauthorized)
  end

  context 'with a not valid token (audience)' do
    before do
      user.update!(id: store.id)
      authenticate(user)
    end

    it 'is not authorized' do
      get :index

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when authenticated' do
    before { authenticate(store) }

    it 'respond ok' do
      get :index

      expect(response).to have_http_status(:ok)
    end

    it 'is unauthorized when store is not active' do
      store.update!(active: false)

      get :index

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
