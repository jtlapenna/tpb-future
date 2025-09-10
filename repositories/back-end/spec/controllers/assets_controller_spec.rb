require 'rails_helper'

describe AssetsController do
  let(:user) { create :user }

  before do
    stub_request :any, /s3\.sa-east-1\.amazonaws.com/
  end

  context '#upload_request' do
    before { authenticate(user) }

    it 'respond ok' do
      get :upload_request, params: { resource: 'products', resource_name: 'image.png' }

      expect(response).to be_ok
    end
  end

  context '#destroy' do
    let(:image) { create :image }

    before { authenticate(user) }

    it 'respond ok' do
      delete :destroy, params: { id: image.id }

      expect(response).to be_ok
    end
  end
end
