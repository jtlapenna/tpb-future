require 'rails_helper'

describe UserTokenController do
  let(:user) { create :user }

  before { authenticate(user) }

  context '#create' do
    it 'respond ok with valid creadentials' do
      post :create, params: { auth: { email: user.email, password: '12345678' } }

      expect(response).to have_http_status :created
    end

    it 'respond with error with invalid creadentials' do
      post :create, params: { auth: { email: user.email, password: '345678' } }

      expect(response).to have_http_status :not_found
    end
  end
end
