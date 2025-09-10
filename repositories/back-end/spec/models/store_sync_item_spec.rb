require 'rails_helper'

describe StoreSyncItem do
  let(:sync_item) { build_stubbed :store_sync_item }

  it 'is valid' do
    expect(sync_item).to be_valid
  end

  it 'is pending' do
    expect(sync_item).to be_pending
  end

  it 'is not valid without stock' do
    sync_item.stock = nil
    expect(sync_item).not_to be_valid
    expect(sync_item.errors[:stock]).to eq ["can't be blank"]
  end

  it 'is not valid with invalid stock' do
    sync_item.stock = 'asd'
    expect(sync_item).not_to be_valid
    expect(sync_item.errors[:stock]).to eq ['is not a number']
  end

  it 'is not valid with negative stock' do
    sync_item.stock = -10
    expect(sync_item).not_to be_valid
    expect(sync_item.errors[:stock]).to eq ['must be greater than or equal to 0']
  end

  it 'is valid without category' do
    sync_item.category = nil

    expect(sync_item).to be_valid
  end

  it 'is valid without brand' do
    sync_item.brand = nil

    expect(sync_item).to be_valid
  end

  it 'fields' do
    sync_item.sku = 'ABC-1'
    sync_item.name = 'Product 1'
    sync_item.category = 'Category 1'
    sync_item.stock = 9
    sync_item.prices = [{ name: 'REG', value: 10 }, { name: 'OMMP', value: 13 }]
    sync_item.brand = 'Brand 1'
    sync_item.active = true

    expect(sync_item.fields).to eq({
      sku: 'ABC-1', name: 'Product 1', category: 'Category 1', stock: 9,
      prices: [{ name: 'REG', value: 10 }, { name: 'OMMP', value: 13 }].map(&:stringify_keys),
      brand: 'Brand 1', active: true
    }.stringify_keys)
  end

  context '#create_store_product!' do
    let!(:att_def) { create :attribute_def, name: 'THC' }
    let!(:att_def_2) { create :attribute_def, name: 'CBD' }
    let(:store) { category.store }
    let(:category) { create :store_category }
    let(:variant) { create :product_variant }
    let(:product) { StoreProduct.last }
    let(:sync) { build :store_sync, store: store }
    let(:sync_item) do
      build :store_sync_item,
            store_sync: sync,
            store_category_id: category.id,
            product_variant_id: variant.id,
            sku: 'ABC', stock: 5, prices: [{ name: 'REG', value: 10.5 }, { name: 'OMMP', value: 8.85 }],
            attributes_values: [
              { name: 'THC', value: '56%' },
              { name: 'CBD', value: '' },
              { name: 'DEF_NOT_FOUND', value: '123' },
              { name: 'TYPe', value: 'SATIVA HYBRID' }
            ]
    end

    before { create :attribute_def, name: 'TYPE', values: ['Sativa Hybrid'], restricted: true }

    it 'create product' do
      expect do
        sync_item.create_store_product!
      end.to change {
        store.store_products.count
      }.by 1
    end

    it 'created product' do
      sync_item.create_store_product!

      expect(product.store_category).to eq category
      expect(product.product_variant).to eq variant
      expect(product.stock).to eq 5
      expect(product.product_values.count).to eq 2
      expect(product.sku).to eq 'ABC'
      expect(product).to be_unpublished
      prices = product.product_values.map { |pv| { name: pv.name, value: pv.value.to_f } }
      expect(prices).to match_array [{ name: 'REG', value: 10.5 }, { name: 'OMMP', value: 8.85 }]
      attributes = product.attribute_values.map { |av| { name: av.attribute_def.name, value: av.value } }
      expect(attributes).to match_array [{ name: 'THC', value: '56%' }, { name: 'TYPE', value: 'Sativa Hybrid' }]
    end

    it 'item is confirmed' do
      sync_item.create_store_product!
      expect(sync_item).to be_confirmed
    end

    it 'publish product when store autopublish products' do
      store.update!(api_autopublish: true)

      sync_item.create_store_product!

      expect(product).to be_published
    end

    it 'restrict type to its values' do
      sync_item.update!(attributes_values: [
                          { name: 'THC', value: '56%' },
                          { name: 'TYPE', value: 'Sativa' }
                        ])

      sync_item.create_store_product!

      attributes = product.attribute_values.map { |av| { name: av.attribute_def.name, value: av.value } }
      expect(attributes).to match_array [{ name: 'THC', value: '56%' }]
    end
  end

  context '#update_store_product!' do
    let!(:att_def) { create :attribute_def, name: 'THC' }
    let!(:att_def_2) { create :attribute_def, name: 'CBD' }
    let!(:att_def_3) { create :attribute_def, name: 'RAS' }
    let(:store) { category.store }
    let(:category) { product.store_category }
    let(:variant) { product.product_variant }
    let(:product) { create :store_product, product_values: [], stock: 7 }
    let(:other_category) { create :store_category, store: store }
    let(:sync) { build :store_sync, store: store }
    let(:sync_item) do
      build :store_sync_item,
            store_category_id: other_category.id,
            store_product_id: product.id,
            product_variant_id: variant.id,
            sku: 'ABC', stock: 5, prices: [{ name: 'REG', value: 10.5 }, { name: 'OMMP', value: 8.85 }],
            store_sync: sync
    end

    it "don't create products" do
      expect do
        sync_item.update_store_product!
      end.not_to change {
        store.store_products.count
      }
    end

    it 'update product sku, stock & prices' do
      sync_item.update_store_product!

      product.reload

      expect(product.store_category).to eq category
      expect(product.product_variant).to eq variant
      expect(product.stock).to eq 5
      expect(product.product_values.count).to eq 2
      expect(product.sku).to eq 'ABC'
      prices = product.product_values.map { |pv| { name: pv.name, value: pv.value.to_f } }
      expect(prices).to match_array [{ name: 'REG', value: 10.5 }, { name: 'OMMP', value: 8.85 }]
    end

    it 'use stock 0 if not active for treez' do
      store.update(
        dispensary_name: 'xxx',
        api_type: 'treez',
        api_key: 'xxx'
      )

      sync_item.stock = 10
      sync_item.active = false
      sync_item.update_store_product!

      product.reload

      expect(product.stock).to eq 0
    end

    it 'use stock for others providers' do
      sync_item.stock = 10
      sync_item.active = nil
      sync_item.update_store_product!

      product.reload

      expect(product.stock).to eq 10
    end

    it 'item is confirmed' do
      sync_item.update_store_product!
      expect(sync_item).to be_confirmed
    end
  end

  context 'deactivated_item?' do
    it 'should be true for treez items inactive' do
      sync_item.store_sync.store = build :treez_store
      sync_item.active = false

      expect(sync_item).to be_deactivated_item
    end

    it 'should be false for non-treez items inactive' do
      sync_item.store_sync.store = build :headset_store
      sync_item.active = false

      expect(sync_item).not_to be_deactivated_item
    end

    it 'sould be false for treez items active' do
      sync_item.store_sync.store = build :treez_store
      sync_item.active = true

      expect(sync_item).not_to be_deactivated_item
    end
  end
end
