require 'rails_helper'

describe AttributeGroupsController do
  let(:user) { create :user }

  before { authenticate(user) }

  context '#index' do
    before do
      get :index
    end

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end

    context 'as client' do
      let(:user) { create :user, client: create(:client) }

      it 'is ok' do
        expect(response).to have_http_status :ok
      end
    end
  end

  context '#create' do
    let(:params) { { attribute_group: { name: 'xxx' } } }
    let(:missing_name_params) { { attribute_group: { name: '' } } }

    it 'respond ok' do
      post :create, params: params
      expect(response).to have_http_status :created
    end

    it 'request error code' do
      post :create, params: missing_name_params

      expect(response).to have_http_status :unprocessable_entity
    end

    context 'as client' do
      let(:user) { create :user, client: create(:client) }

      it 'is forbidden' do
        post :create, params: params

        expect(response).to have_http_status :forbidden
      end
    end
  end

  context '#update' do
    let(:attribute_group) { create :attribute_group }
    let(:params) { { id: attribute_group.id, attribute_group: { name: 'xxx' } } }
    let(:missing_name_params) { { id: attribute_group.id, attribute_group: { name: '' } } }

    it 'respond ok' do
      put :update, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      put :update, params: missing_name_params

      expect(response).to have_http_status :unprocessable_entity
    end

    context 'as client' do
      let(:user) { create :user, client: create(:client) }

      it 'is forbidden' do
        put :update, params: missing_name_params

        expect(response).to have_http_status :forbidden
      end
    end
  end

  context '#show' do
    let(:attribute_group) { create :attribute_group }
    let(:params) { { id: attribute_group.id } }

    it 'respond ok' do
      get :show, params: params
      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :show, params: { id: 'do_not_exists' }

      expect(response).to have_http_status :not_found
    end
  end

  context '#destroy' do
    let(:attribute_group) { create :attribute_group }
    let(:params) { { id: attribute_group.id } }

    it 'respond ok' do
      delete :destroy, params: params

      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      delete :destroy, params: { id: 'do_not_exists' }

      expect(response).to have_http_status :not_found
    end

    context 'as client' do
      let(:user) { create :user, client: create(:client) }

      it 'is forbidden' do
        delete :destroy, params: params

        expect(response).to have_http_status :forbidden
      end
    end
  end
end
