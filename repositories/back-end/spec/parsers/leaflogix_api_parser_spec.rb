require 'rails_helper'

describe LeaflogixApiParser do
  include LeaflogixApiHelper

  let(:store) { create :leaflogix_store }
  let(:parser) { LeaflogixApiParser.new(store_id: store.id) }
  let(:api) { double }
  let(:api_products) { [] }
  let(:api_inventory) { [] }

  before do
    allow(api).to receive(:products).and_return(api_products, [])
    allow(api).to receive(:inventory).and_return(api_inventory, [])
    expect(Leaflogix::ApiClient).to receive(:new).with(
      api_key: store.api_key
    ).and_return(api)
  end

  it 'create sync' do
    expect do
      parser.parse
    end.to change {
      StoreSync.count
    }.by 1
  end

  context 'when products are valid' do
    let(:api_products) { valid_products_json }
    let(:api_inventory) { valid_inventory_json }

    it 'created sync values' do
      sync = parser.parse[:sync]

      expect(sync).to be
      expect(sync.store_sync_items.count).to eq 3

      expect(sync.store_sync_items[0].sku).to eq 171_097
      expect(sync.store_sync_items[0].name).to eq 'BG Chem-3.5g-20.9%THCa'
      expect(sync.store_sync_items[0].description).to eq "BG Chem is an indica dominant strain that is a cross between bubblegum and chem line genetics. \n\nThis strain typically is dominated by myrcene."
      expect(sync.store_sync_items[0].size_name).to eq 'BG Chem-3.5g-20.9%THCa'
      expect(sync.store_sync_items[0].category).to eq 'Buds'
      expect(sync.store_sync_items[0].stock).to eq 6
      expect(sync.store_sync_items[0].brand).to eq "Nature's Heritage"
      expect(sync.store_sync_items[0].active).to be true
      expect(sync.store_sync_items[0].prices.count).to eq 1
      expect(sync.store_sync_items[0].prices).to eq [
        { name: '.4 g', value: 50.0 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[0].images).to eq(
        'primary' => 'https://leaflogixmedia.blob.core.windows.net/product-image/9cca4ca3-65c0-42fc-b77b-3f00f454f881.jpg',
        'thumb' => 'https://leaflogixmedia.blob.core.windows.net/product-image/9cca4ca3-65c0-42fc-b77b-3f00f454f881.jpg'
      )
      expect(sync.store_sync_items[0].tags).to eq []
      expect(sync.store_sync_items[0].attributes_values).to eq [
        { 'name' => 'THC', 'value' => '14.75%' },
        { 'name' => 'CBD', 'value' => '28.31%' }
      ]

      expect(sync.store_sync_items[1].sku).to eq 171_767
      expect(sync.store_sync_items[1].name).to eq 'Oro Blanco Flower 3.5g'
      expect(sync.store_sync_items[1].description).to be_nil
      expect(sync.store_sync_items[1].size_name).to eq 'Oro Blanco Flower 3.5g'
      expect(sync.store_sync_items[1].category).to eq 'Buds'
      expect(sync.store_sync_items[1].stock).to eq 40
      expect(sync.store_sync_items[1].brand).to be_nil
      expect(sync.store_sync_items[1].active).to be false
      expect(sync.store_sync_items[1].prices.count).to eq 1
      expect(sync.store_sync_items[1].prices).to eq [
        { name: '.5 g', value: 30.0 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[1].images).to eq({})
      expect(sync.store_sync_items[1].tags).to eq []
      expect(sync.store_sync_items[1].attributes_values).to eq []

      expect(sync.store_sync_items[2].sku).to eq 171_769
      expect(sync.store_sync_items[2].name).to eq 'Product without detail'
      expect(sync.store_sync_items[2].description).to be_nil
      expect(sync.store_sync_items[2].size_name).to eq 'Product without detail'
      expect(sync.store_sync_items[2].category).to eq nil
      expect(sync.store_sync_items[2].stock).to eq 32
      expect(sync.store_sync_items[2].brand).to be_nil
      expect(sync.store_sync_items[2].active).to be false
      expect(sync.store_sync_items[2].prices.count).to eq 1
      expect(sync.store_sync_items[2].prices).to eq [
        { name: '.7 g', value: 30.23 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[2].images).to eq({})
      expect(sync.store_sync_items[2].tags).to eq []
      expect(sync.store_sync_items[2].attributes_values).to eq []

      expect(sync[:errors]).to be_blank
    end
  end

  context 'with some errors' do
    let(:api_products) { valid_products_json }
    let(:api_inventory) { inventory_with_errors_json }

    it 'created sync values when file is valid' do
      sync = parser.parse

      expect(sync[:sync]).not_to be
      expect(sync[:errors]).to be_present
      expect(sync[:errors]).to eq [
        { row: 2, messages: { sku: ["can't be blank"] } }
      ]
    end
  end

  def valid_products_json
    leaflogix_products
  end

  def valid_inventory_json
    [
      leaflogix_inventory[0],
      leaflogix_inventory[1],
      leaflogix_inventory[3]
    ]
  end

  def inventory_with_errors_json
    [
      leaflogix_inventory[0],
      leaflogix_inventory[2], # Not valid, no sku.
      leaflogix_inventory[1]
    ]
  end
end
