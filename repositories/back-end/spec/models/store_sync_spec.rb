require 'rails_helper'

describe StoreSync do
  let(:sync) { build_stubbed :store_sync }

  it 'is valid' do
    expect(sync).to be_valid
  end

  it 'is pending' do
    expect(sync).to be_pending
  end

  it 'is not valid without store' do
    sync.store = nil
    expect(sync).not_to be_valid
    expect(sync.errors[:store]).to eq ['must exist']
  end

  context 'scopes' do
    let(:client) { create :client }
    let(:user) { create :user, client: client }
    let!(:store) { create :store, client: client, categories_count: 0 }

    it 'owner scope' do
      create :store_sync, store: store
      create :store_sync, store: create(:store, categories_count: 0)

      expect(StoreSync.owner(user).count).to eq 1
    end
  end

  context 'sync with api_automatch' do
    let(:catalog) { create :catalog, store: store }
    let(:store) { create :treez_store, api_automatch: true }
    let(:sync) { create :store_sync, store: store }
    let(:prod_1) { create(:store_product, store: store, stock: 1, weight: 78) }
    let(:prices) { [{ name: 'REG', value: 10.56 }, { name: 'OMMP', value: 8.15 }] }
    let(:sync_1) { create :store_sync_item, store_sync: sync, sku: prod_1.sku, stock: 5, prices: prices, weight: 120 }
    let(:sync_2) do
      create :store_sync_item, store_sync: sync, sku: 'not-exist-1', stock: 10, weight: 340,
                               name: 'Product 1', category: 'flowers', brand: 'new brand', tags: []
    end
    let(:sync_3) do
      create :store_sync_item, store_sync: sync, sku: 'not-exist-3', stock: 2,
                               name: 'Product 2', brand: 'some brand', description: 'product description',
                               category: 'New category', tags: %w[t1 t2 t3 T2 t2]
    end
    let(:sync_4) { create :store_sync_item, store_sync: sync, sku: 'not-exist-4', stock: 2, name: 'Product 3', active: false }
    let(:sync_items) { [sync_1, sync_2, sync_3, sync_4] }

    let(:wildcard_product) { create :product, name: 'Wildcard' }
    let(:wildcard_variant) { create :product_variant, product: wildcard_product }
    let!(:flowers_category) { store.store_categories.create!(name: 'some kind of flowers') }
    let!(:brand) { create :brand, name: 'some Brand' }

    before do
      create_list :brand, 2
      sync_items
      wildcard_variant.touch
      ENV['WILDCARD_VARIANT_ID'] = wildcard_variant.id.to_s
    end

    it 'create store products' do
      expect { sync.process_items }.to change { store.store_products.count }.by 2

      expect(store.store_products.count).to eq 3
    end

    it 'create categories that not exists' do
      expect { sync.process_items }.to change { store.store_categories.count }.by 1

      expect(store.reload.store_categories.map(&:name)).to include 'new category'
    end

    it 'create brands that not exists' do
      expect { sync.process_items }.to change { Brand.count }.by 1

      expect(Brand.all.pluck(:name)).to include 'new brand'
    end

    it 'do not publish auto_confirmed products' do
      sync.process_items

      prod_2 = store.store_products.find_by(sku: 'not-exist-1')
      prod_3 = store.store_products.find_by(sku: 'not-exist-3')

      expect(prod_1).to be_published
      expect(prod_2).to be_unpublished
      expect(prod_3).to be_unpublished
    end

    it 'items status' do
      sync.process_items

      expect(sync_1.reload).to be_auto_matched
      expect(sync_2.reload).to be_auto_confirmed
      expect(sync_3.reload).to be_auto_confirmed
      expect(sync_4.reload).to be_discarded
    end

    it 'create store products' do
      sync.process_items
      store.reload

      expect(store.store_products.map(&:product_variant_id).uniq).to match_array [prod_1.product_variant_id, wildcard_variant.id]
      expect(store.store_products.map(&:store_category_id).uniq.count).to eq 3
      expect(store.store_products.map(&:store_category_id).uniq).to include(prod_1.store_category_id, flowers_category.id)
      expect(store.store_products.map(&:brand).uniq).to include(brand)
      expect(store.store_products.map(&:description).uniq).to include('product description')
      expect(store.store_products.map(&:tag_list)).to eq [[], [], []]
      expect(store.store_products.map(&:weight)).to match_array [78, 340, nil]
    end

    it 'sync tags when store has setting enabled' do
      sync.store.update!(sync_tags: true)
      sync.process_items
      store.reload

      expect(store.store_products.map(&:tag_list).map(&:sort)).to eq [[], [], %w[t1 t2 t3]]
    end
  end

  context 'sync' do
    let(:prices) { [{ name: 'REG', value: 10.56 }, { name: 'OMMP', value: 8.15 }] }
    let(:catalog) { create :catalog, store: store }
    let(:store) { create :treez_store }
    let!(:att_def_1) { create :attribute_def, name: 'THC' }
    let!(:att_def_2) { create :attribute_def, name: 'CBD' }
    let!(:att_def_3) { create :attribute_def, name: 'RAS' }
    let!(:att_def_4) { create :attribute_def, name: 'OTH' }
    let!(:att_def_5) { create :attribute_def, name: 'BLANK ATTR' }
    let!(:att_def_6) { create :attribute_def, name: 'TYPE', restricted: true, values: ['Sativa Hybrid', 'Hybrid'] }
    let!(:att_def_7) { create :attribute_def, name: 'EXISTING_RESTRICTED_ATTR', restricted: true, values: %w[a b] }
    let!(:att_def_8) { create :attribute_def, name: 'NEW_RESTRICTED_ATTR', restricted: true, values: %w[a b] }
    let!(:att_def_9) { create :attribute_def, name: 'EXISTS_DONT_CHANGE' }
    let(:attr_value_1) { create :attribute_value, attribute_def: att_def_1, value: '58%' }
    let(:attr_value_3) { create :attribute_value, attribute_def: att_def_3, value: '1%' }
    let(:attr_value_4) { create :attribute_value, attribute_def: att_def_4, value: '10mg' }
    let(:attr_value_6) { create :attribute_value, attribute_def: att_def_6, value: 'Hybrid' }
    let(:attr_value_7) { create :attribute_value, attribute_def: att_def_7, value: 'a' }
    let(:attr_value_9) { create :attribute_value, attribute_def: att_def_9, value: 'V1' }
    let(:prod_1) do
      create :store_product, store: store, stock: 1, name: 'old name', weight: 20,
                             description: 'old description', store_category: old_category,
                             brand: old_brand, tag_list: %w[t1 T2],
                             attribute_values: [attr_value_1, attr_value_3, attr_value_4, attr_value_6, attr_value_7, attr_value_9]
    end
    let(:prod_2) { create(:store_product, store: store, stock: 1) }
    let(:prod_3) { create(:store_product, store: store, stock: 0) }
    let(:sync_1) do
      create :store_sync_item, store_sync: sync, sku: prod_1.sku, category: 'new category', weight: 120,
                               stock: 5, prices: prices, name: 'new name', description: 'new description', brand: 'new brand', tags: %w[t1 t5],
                               attributes_values: [
                                 { name: 'tHC', value: '10%' },
                                 { name: 'CBd', value: '68%' },
                                 { name: 'RAS', value: '' },
                                 { name: 'BLANK ATTR', value: '' },
                                 { name: 'NON_EXISTING_DEF', value: 'xxx' },
                                 { name: 'TYPE', value: 'SATIVA HYBRID' },
                                 { name: 'EXISTING_RESTRICTED_ATTR', value: 'non-existing' },
                                 { name: 'NEW_RESTRICTED_ATTR', value: 'non-existing' },
                                 { name: 'EXISTS_DONT_CHANGE', value: 'V1' }
                               ]
    end
    let(:sync_2) { create :store_sync_item, store_sync: sync, sku: 'not-exist-1', stock: 10, name: 'Product 1' }
    let(:sync_3) { create :store_sync_item, store_sync: sync, sku: 'not-exist-3', stock: 2, name: 'Product 2', attributes_values: [{ name: 'THC', value: '56%' }, { name: 'CBD', value: '' }] }
    let(:sync_4) { create :store_sync_item, store_sync: sync, sku: 'not-exist-4', stock: 2, name: 'Product 3', active: false }

    let(:existing_products) { [prod_1, prod_2, prod_3] }
    let(:sync_items) { [sync_1, sync_2, sync_3, sync_4] }
    let(:sync) { create :store_sync, store: store }
    let!(:new_category) { create :store_category, store: store, name: 'nEw category' }
    let(:old_category) { create :store_category, store: store, name: 'old category' }
    let(:old_brand) { create :brand, name: 'old brand' }
    let!(:new_brand) { create :brand, name: 'new brand' }

    before do
      sync_items
      prod_1.product_values.create!(name: 'REG', value: 11.50)
      prod_1.product_values.create!(name: 'OTHER', value: 2)
      create :product, name: 'Product 1'
    end

    it 'update matched products' do
      expect(sync).to receive(:similar_products?).with('Product 1').and_return true
      expect(sync).to receive(:similar_products?).with('Product 2').and_return false

      sync.process_items
      sync.reload
      existing_products.each(&:reload)
      sync_items.each(&:reload)

      expect(prod_1.name).to eq 'old name'
      expect(prod_1.description).to eq 'old description'
      expect(prod_1.store_category_id).to eq old_category.id
      expect(prod_1.brand_id).to eq old_brand.id
      expect(prod_1.stock).to eq 5
      expect(prod_1.product_values.count).to eq 2
      expect(prod_1.tag_list.sort).to eq %w[T2 t1]
      prices = prod_1.product_values.map { |pv| { name: pv.name, value: pv.value.to_f } }
      expect(prices).to match_array [{ name: 'REG', value: 10.56 }, { name: 'OMMP', value: 8.15 }]
      attributes = prod_1.attribute_values.map { |av| { name: av.attribute_def.name, value: av.value } }
      expect(attributes).to match_array [
        { name: 'THC', value: '58%' },
        { name: 'RAS', value: '1%' },
        { name: 'OTH', value: '10mg' },
        { name: 'TYPE', value: 'Hybrid' },
        { name: 'EXISTING_RESTRICTED_ATTR', value: 'a' },
        { name: 'EXISTS_DONT_CHANGE', value: 'V1' }
      ]

      expect(prod_2.stock).to eq 1
      expect(prod_3.stock).to eq 0

      expect(sync_1).to be_auto_matched
      expect(sync_1.store_product_id).to eq prod_1.id

      expect(sync_2).to be_to_confirm
      expect(sync_2.store_product_id).to be_nil

      expect(sync_3).to be_unmatched
      expect(sync_3.store_product_id).to be_nil

      expect(sync_4).to be_discarded
      expect(sync_4.store_product_id).to be_nil
    end

    context 'when all items are processed' do
      let(:store) { create :store }
      let(:sync_items) { [] }
      let(:sync) { create :store_sync, store: store, status: :pending }

      it 'finish sync' do
        expect do
          sync.process_items
        end.to change {
          sync.reload.status
        }.from('pending').to 'finished'
      end
    end

    context 'when all items are discarded' do
      let(:store) { create :treez_store }
      let(:sync_items) { [sync_4] }
      let(:sync) { create :store_sync, store: store, status: :pending }

      it 'finish sync' do
        expect do
          sync.process_items
        end.to change {
          sync.reload.status
        }.from('pending').to 'finished'
      end
    end

    context 'when override_on_sync set' do
      let(:store) { create :treez_store, override_on_sync: true }

      before do
        expect(sync).to receive(:similar_products?).with('Product 1').and_return true
        expect(sync).to receive(:similar_products?).with('Product 2').and_return false

        sync.process_items
        sync.reload
        existing_products.each(&:reload)
        sync_items.each(&:reload)
      end

      it 'update matched products' do
        expect(prod_1.name).to eq 'new name'
        expect(prod_1.description).to eq 'new description'
        expect(prod_1.store_category).to eq new_category
        expect(prod_1.brand_id).to eq new_brand.id
        expect(prod_1.tag_list.sort).to eq %w[T2 t1]
        expect(prod_1.attribute_values.length).to eq 5
        expect(prod_1.weight).to eq 120

        attributes = prod_1.attribute_values.map { |av| { name: av.attribute_def.name, value: av.value } }
        expect(attributes).to match_array [
          { name: 'THC', value: '10%' },
          { name: 'CBD', value: '68%' },
          { name: 'OTH', value: '10mg' },
          { name: 'TYPE', value: 'Sativa Hybrid' },
          { name: 'EXISTS_DONT_CHANGE', value: 'V1' }
        ]

        expect(prod_2.attribute_values.length).to eq 0
        expect(prod_3.attribute_values.length).to eq 0
      end

      context 'when sync tags' do
        let(:store) { create :treez_store, override_on_sync: true, sync_tags: true }

        it 'update matched product tags' do
          expect(prod_1.tag_list.sort).to eq %w[T2 t1 t5]
        end
      end
    end
  end
end
