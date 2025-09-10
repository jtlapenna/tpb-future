require 'rails_helper'

describe StoreSyncsController do
  let(:user) { create :user }
  let(:file) { Tempfile.new('products.csv') }
  let(:rows) do
    [
      %w[sku name category stock],
      [' ABC-1 ', ' Product 1 ', ' Category 1 ', '10']
    ]
  end

  before do
    CSV.open(file, 'w') do |csv|
      rows.each { |row| csv << row }
    end
    authenticate(user)
  end

  context '#create' do
    let(:store) { create :store }
    let(:params) do
      {
        store_id: store.id,
        file: Rack::Test::UploadedFile.new(file, 'text/x-csv')
      }
    end
    let(:missing_name_params) { { store_id: store.id } }

    before do
      allow(Product).to receive(:search).and_return double(count: 0)
    end

    it 'respond ok' do
      post :create, params: params

      expect(response).to have_http_status :created
    end

    it 'request error code' do
      post :create, params: missing_name_params

      expect(response).to have_http_status :unprocessable_entity
    end

    context 'api sync' do
      let(:store) { create :treez_store }
      let(:params) { { store_id: store.id } }

      before do
        stub_request(:post, 'https://api.treez.io/v1.0/dispensary/xxx/config/api/gettokens').with(
          body: "apikey=#{store.api_key}&client_id=#{store.api_client_id}",
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8' }
        ).to_return(
          status: 200,
          body: { access_token: 'token', resultCode: 'SUCCESS' }.to_json,
          headers: { 'Content-Type' => 'application/json; charset=utf-8' }
        )

        stub_request(
          :get, 'https://api.treez.io/v1.0/dispensary/xxx/menu/product_list?limit=500&offset=0&stock=all&type=all'
        ).with(
          headers: { 'Authorization' => 'bearer token', 'client-Id' => store.api_client_id }
        ).and_return(body: { product_list: [] }.to_json)
      end

      it 'respond ok' do
        post :create, params: params

        expect(response).to have_http_status :created
      end
    end
  end

  context '#show' do
    let(:store_sync) { create :store_sync }
    let(:params) { { id: store_sync.id, store_id: store_sync.store_id } }

    it 'respond ok' do
      get :show, params: params

      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      get :show, params: { id: 'do_not_exists', store_id: store_sync.store_id }

      expect(response).to have_http_status :not_found
    end
  end

  context '#finish' do
    let(:store_sync) { create :store_sync }
    let(:params) { { id: store_sync.id, store_id: store_sync.store_id } }

    it 'respond ok' do
      put :finish, params: params

      expect(response).to have_http_status :ok
    end

    it 'request error code' do
      put :finish, params: params.merge(id: 'do_not_exists')

      expect(response).to have_http_status :not_found
    end
  end

  context '#sync_item' do
    let(:sync) { create :store_sync }
    let(:item) { sync.store_sync_items.last }
    let(:variant) { create :product_variant }
    let(:cat_category) { create :store_category, store: sync.store }
    let(:params) do
      {
        store_id: sync.store_id,
        id: sync.id,
        store_sync_item_id: item.id,
        store_category_id: cat_category.id,
        product_variant_id: variant.id
      }
    end

    before do
      sync.store_sync_items << build(:store_sync_item, sku: '12-3', stock: 1, status: :to_confirm, prices: [])
      sync.store_sync_items << build(
        :store_sync_item, sku: '12-4', stock: 2, status: :to_confirm,
                          prices: [{ name: 'OMMP', value: 10.67 }]
      )
    end

    it 'respond ok' do
      post :sync_item, params: params

      expect(response).to have_http_status :ok
    end

    it 'respond unprocessable_entity when sync is not valid' do
      sync.store_sync_items << build(:store_sync_item, sku: '12-3', stock: 2, status: :to_confirm, prices: [])

      item = sync.store_sync_items.first
      item.store_category_id = cat_category.id
      item.product_variant_id = variant.id
      item.create_store_product!

      post :sync_item, params: params

      expect(response).to have_http_status :unprocessable_entity
    end
  end
end
