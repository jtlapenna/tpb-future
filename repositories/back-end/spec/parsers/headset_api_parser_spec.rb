require 'rails_helper'

describe HeadsetApiParser do
  include HeadsetApiHelper

  let(:store) { create :headset_store, api_store_id: 'omofmedicine', api_key: 'xxx' }
  let(:parser) { HeadsetApiParser.new(store_id: store.id) }
  let(:api) { double }
  let(:api_products) { [] }

  before do
    allow(api).to receive(:products).and_return(api_products, [])
    expect(Headset::ApiClient).to receive(:new)
      .with(api_store_id: 'omofmedicine', api_key: 'xxx', api_partner: 'thepeakbeyond')
      .and_return(api)
  end

  it 'create sync' do
    expect do
      parser.parse
    end.to change {
      StoreSync.count
    }.by 1
  end

  context 'when products are valid' do
    let(:api_products) { valid_product_json }

    it 'created sync values' do
      sync = parser.parse[:sync]

      expect(sync).to be
      expect(sync.store_sync_items.count).to eq 5

      expect(sync.store_sync_items[0].sku).to eq '123'
      expect(sync.store_sync_items[0].name).to eq 'Monster Gummy - Strawberry'
      expect(sync.store_sync_items[0].category).to eq 'Edible (Solid)'
      expect(sync.store_sync_items[0].stock).to eq 10
      expect(sync.store_sync_items[0].brand).to eq 'Monster'
      expect(sync.store_sync_items[0].active).to be
      expect(sync.store_sync_items[0].prices.count).to eq 1
      expect(sync.store_sync_items[0].prices).to eq [{ name: '10.00 Gram', value: 10.5 }].map(&:stringify_keys)

      expect(sync.store_sync_items[1].sku).to eq '1234'
      expect(sync.store_sync_items[1].name).to eq 'Kushmas Ornament'
      expect(sync.store_sync_items[1].category).to eq 'Paraphernalia'
      expect(sync.store_sync_items[1].stock).to eq 25
      expect(sync.store_sync_items[1].brand).to be_nil
      expect(sync.store_sync_items[1].active).to be
      expect(sync.store_sync_items[1].prices.count).to eq 1
      expect(sync.store_sync_items[1].prices).to eq [{ name: ' Each', value: 11.5 }].map(&:stringify_keys)

      expect(sync.store_sync_items[2].sku).to eq '12345'
      expect(sync.store_sync_items[2].name).to eq 'Monster Gummy - Strawberry'
      expect(sync.store_sync_items[2].category).to eq 'Edible (Solid)'
      expect(sync.store_sync_items[2].stock).to eq 3
      expect(sync.store_sync_items[2].brand).to eq 'Monster'
      expect(sync.store_sync_items[2].active).to be
      expect(sync.store_sync_items[2].prices.count).to eq 1
      expect(sync.store_sync_items[2].prices).to eq [{ name: '10.00 Gram', value: 12.5 }].map(&:stringify_keys)

      expect(sync.store_sync_items[3].sku).to eq '1234567'
      expect(sync.store_sync_items[3].name).to eq 'Kushmas Ornament'
      expect(sync.store_sync_items[3].category).to eq 'Paraphernalia'
      expect(sync.store_sync_items[3].stock).to eq 5
      expect(sync.store_sync_items[3].brand).to be_nil
      expect(sync.store_sync_items[3].active).to be
      expect(sync.store_sync_items[3].prices.count).to eq 1
      expect(sync.store_sync_items[3].prices).to eq [{ name: ' Each', value: 15.5 }].map(&:stringify_keys)

      expect(sync.store_sync_items[4].sku).to eq '123456'
      expect(sync.store_sync_items[4].name).to eq 'Kushmas Ornament'
      expect(sync.store_sync_items[4].category).to eq 'Paraphernalia'
      expect(sync.store_sync_items[4].stock).to eq 0
      expect(sync.store_sync_items[4].brand).to be_nil
      expect(sync.store_sync_items[4].active).to be
      expect(sync.store_sync_items[4].prices.count).to eq 1
      expect(sync.store_sync_items[4].prices).to eq [{ name: ' Each', value: 13.5 }].map(&:stringify_keys)
    end
  end

  context 'with some errors' do
    let(:api_products) { product_with_errors_json }

    it 'created sync values when file is valid' do
      sync = parser.parse

      expect(sync[:sync]).not_to be
      expect(sync[:errors]).to be_present
      expect(sync[:errors]).to eq [
        { row: 3, messages: { sku: ["can't be blank"] } }
      ]
    end
  end

  def valid_product_json
    [products_json[0], products_json[1], products_json[2], products_json[5], products_json[3]]
  end

  def product_with_errors_json
    [
      products_json[0],
      products_json[3], # Not valid, stock is negative.
      products_json[4], # Not valid, no sku.
      products_json[1]
    ]
  end

  def products_json
    [
      headset_products[0].dup.merge(sku: '123', quantityInStock: 10, price: 10.5),
      headset_products[1].dup.merge(sku: '1234', quantityInStock: 25, price: 11.5),
      headset_products[0].dup.merge(sku: '12345', quantityInStock: 3, price: 12.5),
      headset_products[1].dup.merge(sku: '123456', quantityInStock: -4, price: 13.5),
      headset_products[0].dup.merge(sku: nil, quantityInStock: 5, price: 14.5),
      headset_products[1].dup.merge(sku: '1234567', quantityInStock: 5, price: 15.5)
    ]
  end
end
