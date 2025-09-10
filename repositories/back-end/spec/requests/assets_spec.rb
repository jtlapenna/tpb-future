require 'rails_helper'

describe 'Assets API' do
  let(:user) { create :user }

  context '#upload_request' do
    let(:params) { { resource: 'products', resource_name: 'image.png' } }

    it 'return url' do
      get upload_request_assets_path, params: params, headers: auth_headers(user)

      expect(json).to have_key 'url_data'
      expect(json['url_data']).to have_key 'upload_url'
      expect(json['url_data']).to have_key 'public_url'
      expect(json['url_data']['upload_url']).to match %r{https://test-images\.s3\.sa-east-1\.amazonaws\.com/products/.*/image\.png}
      expect(json['url_data']['public_url']).to match %r{https://test-images\.s3\.sa-east-1\.amazonaws\.com/products/.*/image\.png$}
    end

    it 'require resource param' do
      get upload_request_assets_path, params: { resource_name: 'product_1.png' }, headers: auth_headers(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'require resource_name param' do
      get upload_request_assets_path, params: { resource: 'products_a' }, headers: auth_headers(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context '#destroy' do
    let(:image) { create :image }

    before do
      image.touch
      stub_request :any, /s3\.sa-east-1\.amazonaws.com/
    end

    it 'destroy the image' do
      expect do
        delete asset_path(image), headers: auth_headers(user)
      end.to change {
        Image.count
      }.by -1
    end
  end
end
