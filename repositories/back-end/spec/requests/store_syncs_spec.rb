require 'rails_helper'

describe 'Store sync API' do
  let(:user) { create :user }
  let(:store) { create :store }

  let(:file) { Tempfile.new('products.csv') }
  let(:rows) do
    [
      %w[sku name category stock OMMP],
      [' ABC-1 ', ' Product 1 ', ' Category 1 ', '10', 10.5],
      ['ABC-2', ' Product 2', 'Category 1', 8, 10.5],
      ['ABC-3', 'Product 3 ', ' Category 2', 0, 10.5]
    ]
  end

  before do
    CSV.open(file, 'w') do |csv|
      rows.each { |row| csv << row }
    end
    store.store_prices.create!(name: 'OMMP')
  end

  def store_sync_json(sync)
    s_json = sync.as_json(only: [:id], include: {
                            store_sync_items: {
                              only: %i[id status],
                              methods: %i[sku name size_name category stock brand store_product_id]
                            }
                          })
    s_json
  end

  context '#create' do
    let(:params) { { file: Rack::Test::UploadedFile.new(file, 'text/x-csv') } }
    let(:missing_name_params) { {} }
    let(:sync) { StoreSync.last }

    before do
      allow(Product).to receive(:search).and_return double(count: 0)
    end

    it 'create sync' do
      expect do
        post store_store_syncs_path(store), params: params, headers: auth_headers(user)
      end.to change {
        StoreSync.count
      }.by 1
    end

    it 'respond with sync' do
      post store_store_syncs_path(store), params: params, headers: auth_headers(user)

      expect(json).to have_key('store_sync')
      expect(json['store_sync']).to eq store_sync_json(sync)
    end

    context 'return errors' do
      let(:params) { { file: Rack::Test::UploadedFile.new(file, 'text/x-csv') } }
      let(:rows) do
        [
          %w[sku name category stock OMMP],
          [' ABC-1 ', ' Product 1 ', ' Category 1 ', '-10', 1],
          ['ABC-2', ' Product 2', 'Category 1', 8, 1],
          [nil, 'Product 3 ', ' Category 2', 0, 1]
        ]
      end

      it 'return errors' do
        post store_store_syncs_path(store), params: params, headers: auth_headers(user)

        expect(json).to have_key('errors')
        expect(json['errors']).to eq([
                                       { 'row' => 1, 'messages' => { 'stock' => ['must be greater than or equal to 0'] } },
                                       { 'row' => 3, 'messages' => {
                                         'sku' => ["can't be blank"]
                                       } }
                                     ])
      end
    end
  end

  context '#sync_item' do
    let(:sync) { create :store_sync }
    let(:item) { sync.store_sync_items.last }
    let(:variant) { create :product_variant }
    let(:new_product) { StoreProduct.last }
    let(:store_category) { create :store_category, store: sync.store }
    let(:params) do
      {
        store_sync_item_id: item.id,
        store_category_id: store_category.id,
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

    shared_examples_for 'process item method' do
      it 'item is confirmed' do
        post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)

        expect(item.reload).to be_confirmed
      end

      it 'respond with sync' do
        post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)

        expect(json['store_sync']).to eq store_sync_json(sync.reload)
      end

      %i[auto_matched! confirmed! pending! auto_confirmed!].each do |state|
        it "not process #{state} items" do
          item.send state
          expect do
            post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)
          end.not_to change {
            StoreProduct.count
          }
        end
      end
    end

    context 'without store_product_id param' do
      it 'should not create catalog product' do
        expect do
          post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)
        end.to change {
          StoreProduct.count
        }.by 1
      end

      it 'created catalog product' do
        post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)

        expect(new_product.store_category_id).to eq store_category.id
        expect(new_product.product_variant_id).to eq variant.id
        expect(new_product.product_values.count).to eq 1

        prices = new_product.product_values.map { |pv| { name: pv.name, value: pv.value.to_f } }
        expect(prices).to match_array [{ name: 'OMMP', value: 10.67 }]
      end

      it "update's item variant & category" do
        post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)

        expect(item.reload).to have_attributes store_category_id: store_category.id.to_s, product_variant_id: variant.id.to_s, store_product_id: nil
      end

      it_behaves_like 'process item method'
    end

    context 'with store_product_id param' do
      let(:other_category) { create :store_category, store: store_category.store }
      let!(:store_product) { create :store_product, sku: 'xxx', stock: 100, product_values: [], store_category: other_category, product_variant: variant }
      let(:params) do
        {
          store_sync_item_id: item.id,
          store_product_id: store_product.id,
          store_category_id: store_category.id,
          product_variant_id: variant.id
        }
      end

      it 'should not create store product' do
        expect do
          post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)
        end.not_to change {
          StoreProduct.count
        }
      end

      it 'should update store product sku, prices and stock' do
        post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)

        expect(store_product.reload).to have_attributes sku: '12-4', stock: 2, product_variant: variant, store_category: other_category

        prices = store_product.product_values.map { |pv| { name: pv.name, value: pv.value.to_f } }
        expect(prices).to match_array [{ name: 'OMMP', value: 10.67 }]
      end

      it "update's item variant & store product" do
        post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)

        expect(item.reload).to have_attributes store_category_id: nil, product_variant_id: variant.id.to_s, store_product_id: store_product.id.to_s
      end

      it_behaves_like 'process item method'
    end

    context 'on error' do
      before do
        sync.store_sync_items << build(:store_sync_item, sku: '12-3', stock: 3, status: :to_confirm)
        item = sync.store_sync_items.first
        item.store_category_id = store_category.id
        item.product_variant_id = variant.id
        item.create_store_product!

        post sync_item_store_store_sync_path(sync.store, sync), params: params, headers: auth_headers(user)
      end

      it 'return errors' do
        expect(json).to have_key 'errors'
        expect(json['errors']).to eq ['Validation failed: Sku has already been taken']
      end
    end
  end

  context '#show' do
    let(:sync) { create :store_sync }

    it 'return catalog sync' do
      get store_store_sync_path(sync.store, sync), headers: auth_headers(user)

      expect(json).to have_key('store_sync')
      expect(json['store_sync']).to eq store_sync_json(sync)
    end
  end

  context '#finish' do
    let(:sync) { create :store_sync }

    it 'finish sync' do
      put finish_store_store_sync_path(sync.store, sync), headers: auth_headers(user)

      expect(sync.reload).to be_finished
    end

    it 'on error' do
      sync_mock = double
      expect(sync_mock).to receive(:finished!).and_raise 'Error!'
      expect(sync_mock).to receive(:policy_class).and_return StoreSyncPolicy
      expect(StoreSync).to receive(:find).and_return sync_mock

      put finish_store_store_sync_path(sync.store, sync), headers: auth_headers(user)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to have_key 'error'
    end
  end
end
