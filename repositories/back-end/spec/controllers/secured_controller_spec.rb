require 'rails_helper'

describe ApplicationController do
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

  context 'when authenticated' do
    before { authenticate(user) }

    it 'redirect to login' do
      get :index

      expect(response).to be_ok
    end
  end
end
