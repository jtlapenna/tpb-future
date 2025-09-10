require 'rails_helper'

describe UsersController do
  let(:admin_user) { create :user }

  before { authenticate(admin_user) }

  context '#current' do
    it 'respond ok' do
      get :current
      expect(response).to have_http_status :ok
    end
  end

  context '#index' do
    before do
      get :index
    end

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#create' do
    let(:params) { { user: { name: 'xxx', email: 'an@email.com', password: 'the_password', password_confirmation: 'the_password' } } }
    let(:missing_name_params) { { user: { active: false } } }

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
    let(:user) { create :user }
    let(:params) { { id: user.id, user: { name: 'xxx' } } }
    let(:missing_name_params) { { id: user.id, user: { email: '' } } }

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
    let(:user) { create :user }
    let(:params) { { id: user.id } }

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
