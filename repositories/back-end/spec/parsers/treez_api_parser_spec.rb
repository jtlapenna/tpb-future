require 'rails_helper'

describe TreezApiParser do
  let(:store) { create :treez_store }
  let(:parser) { TreezApiParser.new(store_id: store.id) }
  let(:api) { double }
  let(:api_products) { [] }

  before do
    store.store_prices.create!(name: 'REG')
    store.store_prices.create!(name: 'OMMP')
    allow(api).to receive(:products).with(type_name: 'all').and_return(api_products, [])
    expect(Treez::ApiClient).to receive(:new)
      .with(
        dispensary_name: store.dispensary_name,
        api_key: store.api_key,
        api_version: store.api_version,
        client_id: store.api_client_id
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
    let(:api_products) { valid_product_json }

    it 'created sync values' do
      sync = parser.parse[:sync]

      expect(sync).to be
      expect(sync.store_sync_items.count).to eq 6

      expect(sync.store_sync_items[0].sku).to eq 'ABC-1-1'
      expect(sync.store_sync_items[0].name).to eq 'HIATUS KUSH'
      expect(sync.store_sync_items[0].description).to eq 'HIATUS KUSH description'
      expect(sync.store_sync_items[0].size_name).to eq 'WEDDING CAKE 1g'
      expect(sync.store_sync_items[0].category).to eq 'CARTRIDGE'
      expect(sync.store_sync_items[0].stock).to eq 5
      expect(sync.store_sync_items[0].brand).to eq 'eden extracts'
      expect(sync.store_sync_items[0].active).to be
      expect(sync.store_sync_items[0].prices.count).to eq 1
      expect(sync.store_sync_items[0].prices).to eq [
        { name: 'WEDDING CAKE 1g', value: 18.306636 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[0].images).to eq(
        'primary' => 'https://large.jpg',
        'thumb' => 'https://cropped.jpg'
      )
      expect(sync.store_sync_items[0].attributes_values).to eq([
                                                                 { 'name' => 'THC', 'value' => '45%' },
                                                                 { 'name' => 'CBD', 'value' => '0.0 mg' },
                                                                 { 'name' => 'TYPE', 'value' => 'INDICA' }
                                                               ])
      expect(sync.store_sync_items[0].tags).to eq(%w[cerebral euphoric uplift])

      expect(sync.store_sync_items[1].sku).to eq 'ABC-1-2'
      expect(sync.store_sync_items[1].name).to eq 'HIATUS KUSH'
      expect(sync.store_sync_items[1].description).to eq 'HIATUS KUSH description'
      expect(sync.store_sync_items[1].size_name).to eq 'WEDDING CAKE 1.75g'
      expect(sync.store_sync_items[1].category).to eq 'CARTRIDGE'
      expect(sync.store_sync_items[1].stock).to eq 6
      expect(sync.store_sync_items[1].brand).to eq 'eden extracts'
      expect(sync.store_sync_items[1].active).to be
      expect(sync.store_sync_items[1].prices.count).to eq 1
      expect(sync.store_sync_items[1].prices).to eq [
        { name: 'WEDDING CAKE 1.75g', value: 32.036613 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[1].images).to eq(
        'primary' => 'https://large.jpg',
        'thumb' => 'https://cropped.jpg'
      )
      expect(sync.store_sync_items[1].attributes_values).to eq([
                                                                 { 'name' => 'THC', 'value' => '45%' },
                                                                 { 'name' => 'CBD', 'value' => '0.0 mg' },
                                                                 { 'name' => 'TYPE', 'value' => 'INDICA' }
                                                               ])
      expect(sync.store_sync_items[1].tags).to eq(%w[cerebral euphoric uplift])

      expect(sync.store_sync_items[2].sku).to eq 'ABC-2-1'
      expect(sync.store_sync_items[2].name).to eq 'Tangie Pod'
      expect(sync.store_sync_items[2].description).to eq 'Tangie Pod description'
      expect(sync.store_sync_items[2].size_name).to eq '0.5 gram'
      expect(sync.store_sync_items[2].category).to eq 'CARTRIDGE'
      expect(sync.store_sync_items[2].stock).to eq 2
      expect(sync.store_sync_items[2].brand).to eq 'eden extracts 2'
      expect(sync.store_sync_items[2].active).to be
      expect(sync.store_sync_items[2].prices.count).to eq 1
      expect(sync.store_sync_items[2].prices).to eq [
        { name: '0.5 gram', value: 23.5 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[2].images).to eq(
        'primary' => 'https://large_2.jpg',
        'thumb' => 'https://large_2.jpg'
      )
      expect(sync.store_sync_items[2].attributes_values).to eq([
                                                                 { 'name' => 'THC', 'value' => '0.0 mg' },
                                                                 { 'name' => 'CBD', 'value' => '36%' },
                                                                 { 'name' => 'TYPE', 'value' => 'HYBRID' }
                                                               ])
      expect(sync.store_sync_items[2].tags).to eq(['cerebral'])

      expect(sync.store_sync_items[3].sku).to eq 'ABC-3-1'
      expect(sync.store_sync_items[3].name).to eq 'Tangerine Haze Fresh Frozen'
      expect(sync.store_sync_items[3].description).to eq 'Tangerine Haze Fresh Frozen description'
      expect(sync.store_sync_items[3].size_name).to eq 'Tangerine Haze Fresh Frozen'
      expect(sync.store_sync_items[3].category).to eq 'CARTRIDGE'
      expect(sync.store_sync_items[3].stock).to eq 3
      expect(sync.store_sync_items[3].brand).to be_nil
      expect(sync.store_sync_items[3].active).to be
      expect(sync.store_sync_items[3].prices.count).to eq 1
      expect(sync.store_sync_items[3].prices).to eq [
        { name: 'Tangerine Haze Fresh Frozen', value: 25.5 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[3].attributes_values).to eq([
                                                                 { 'name' => 'THC', 'value' => '50.0 mg' },
                                                                 { 'name' => 'CBD', 'value' => '0.0 mg' },
                                                                 { 'name' => 'TYPE', 'value' => '' }
                                                               ])
      expect(sync.store_sync_items[3].tags).to eq([])

      expect(sync.store_sync_items[4].sku).to eq 'ABC-5-1'
      expect(sync.store_sync_items[4].name).to eq 'Tangerine Haze Fresh Frozen (disabled)'
      expect(sync.store_sync_items[4].description).to eq 'Tangerine Haze Fresh Frozen description'
      expect(sync.store_sync_items[4].size_name).to eq 'Tangerine Haze Fresh Frozen'
      expect(sync.store_sync_items[4].category).to eq 'CARTRIDGE'
      expect(sync.store_sync_items[4].stock).to eq 3
      expect(sync.store_sync_items[4].brand).to be_nil
      expect(sync.store_sync_items[4].active).not_to be
      expect(sync.store_sync_items[4].prices.count).to eq 1
      expect(sync.store_sync_items[4].prices).to eq [
        { name: 'Tangerine Haze Fresh Frozen', value: 25.5 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[4].attributes_values).to eq []
      expect(sync.store_sync_items[4].tags).to eq([])

      expect(sync.store_sync_items[5].sku).to eq 'ABC-6-1'
      expect(sync.store_sync_items[5].name).to eq 'Tangerine Haze Fresh Frozen (disabled)'
      expect(sync.store_sync_items[5].description).to eq 'Tangerine Haze Fresh Frozen description'
      expect(sync.store_sync_items[5].size_name).to eq 'Tangerine Haze Fresh Frozen'
      expect(sync.store_sync_items[5].category).to eq 'CARTRIDGE'
      expect(sync.store_sync_items[5].stock).to eq 3
      expect(sync.store_sync_items[5].brand).to be_nil
      expect(sync.store_sync_items[5].active).not_to be
      expect(sync.store_sync_items[5].prices.count).to eq 1
      expect(sync.store_sync_items[5].prices).to eq [
        { name: 'Tangerine Haze Fresh Frozen', value: 25.5 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[5].tags).to eq([])
      expect(sync.store_sync_items[5].images).to eq(
        'primary' => 'https://cropped.jpg',
        'thumb' => 'https://cropped.jpg'
      )
      expect(sync.store_sync_items[5].attributes_values).to eq []
    end
  end

  context 'with some errors' do
    let(:api_products) { product_with_errors_json }

    it 'created sync values when file is valid' do
      sync = parser.parse

      expect(sync[:sync]).not_to be
      expect(sync[:errors]).to be_present
      expect(sync[:errors]).to eq [
        { row: 2, messages: { stock: ['must be greater than or equal to 0'] } },
        { row: 3, messages: { sku: ["can't be blank"] } }
      ]
    end
  end

  def valid_product_json
    [products_json[0], products_json[1], products_json[2], products_json[5], products_json[6]]
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
    [{
      "type": 'CARTRIDGE',
      "product_id": 'ABC-1',
      "product_name": 'HIATUS KUSH',
      "live_inventory_quantity": 11,
      "brand": 'eden extracts',
      "active": true,
      "description": 'HIATUS KUSH description',
      "images": {
        large_image: 'https://large.jpg',
        cropped_image: 'https://cropped.jpg'
      },
      "attributes": {
        "effects": %w[
          CEREBRAL
          EUPHORIC
          UPLIFT
        ],
        "thc_percentage": 45,
        "cbd_percentage": nil,
        "cbd_ratio": nil,
        "total_mg_thc": nil,
        "total_mg_cbd": 0.0
      },
      "size_list": [{
        "product_size_name": 'WEDDING CAKE 1g',
        "price_sell": 18.306636,
        "size_id": 'ABC-1-1',
        "size": 1,
        "product_unit": 'gram',
        "type": 'CARTRIDGE',
        "live_inventory_quantity": 5
      }, {
        "product_size_name": 'WEDDING CAKE 1.75g',
        "price_sell": 32.036613,
        "size_id": 'ABC-1-2',
        "type": 'CARTRIDGE',
        "live_inventory_quantity": 6
      }],
      "classifications": [
        'INDICA'
      ]
    }, {
      "type": 'CARTRIDGE',
      "product_id": 'ABC-2',
      "product_name": 'Tangie Pod',
      "live_inventory_quantity": 4,
      "brand": 'eden extracts 2',
      "description": 'Tangie Pod description',
      "active": true,
      "images": {
        large_image: 'https://large_2.jpg'
      },
      "attributes": {
        "effects": ['CEREBRAL'],
        "thc_percentage": nil,
        "cbd_percentage": 36,
        "cbd_ratio": nil,
        "total_mg_thc": 0.0,
        "total_mg_cbd": nil
      },
      "size_list": [{
        "product_size_name": 'Tangie pod ',
        "product_unit": 'gram',
        "price_sell": 23.5,
        "size_id": 'ABC-2-1',
        "size": 0.5,
        "type": 'CARTRIDGE',
        "live_inventory_quantity": 2
      }],
      "classifications": %w[
        HYBRID INDICA SATIVA
      ]
    }, {
      "type": 'CARTRIDGE',
      "product_id": 'ABC-3',
      "product_name": 'Tangerine Haze Fresh Frozen',
      "description": 'Tangerine Haze Fresh Frozen description',
      "live_inventory_quantity": 7,
      "active": true,
      "attributes": {
        "effects": [],
        "thc_percentage": nil,
        "cbd_percentage": nil,
        "cbd_ratio": nil,
        "total_mg_thc": 50.0,
        "total_mg_cbd": 0.0
      },
      "size_list": [{
        "product_size_name": 'Tangerine Haze Fresh Frozen',
        "price_sell": 25.5,
        "size_id": 'ABC-3-1',
        "type": 'CARTRIDGE',
        "live_inventory_quantity": 3
      }],
      "classifications": []
    }, {
      "type": 'CARTRIDGE',
      "product_id": 'ABC-4',
      "product_name": 'Sueno Live Resin Sugar',
      "description": 'Sueno Live Resin Sugar description',
      "live_inventory_quantity": -6,
      "brand": 'eden extracts',
      "active": true,
      "attributes": {
        "effects": nil,
        "thc_percentage": nil,
        "cbd_percentage": nil,
        "cbd_ratio": nil,
        "total_mg_thc": 1000.0,
        "total_mg_cbd": 0.0
      },
      "size_list": [{
        "product_size_name": 'Sueno Live Resin Sugar',
        "price_sell": 15.5,
        "size_id": 'ABC-4-1',
        "type": 'CARTRIDGE',
        "live_inventory_quantity": -3
      }]
    }, {
      "type": 'CARTRIDGE',
      "product_id": nil,
      "product_name": 'Sour Diesel Pod',
      "description": 'Sour Diesel Pod description',
      "live_inventory_quantity": 10,
      "active": true,
      "attributes": {
        "some": 'value',
        "thc_percentage": nil,
        "cbd_percentage": nil,
        "cbd_ratio": nil,
        "total_mg_thc": 500.0,
        "total_mg_cbd": 0.0
      },
      "size_list": [{
        "product_size_name": 'Sour Diesel Pod',
        "price_sell": 5.5,
        "size_id": nil,
        "type": 'CARTRIDGE',
        "live_inventory_quantity": 5
      }]
    }, {
      "type": 'CARTRIDGE',
      "product_id": 'ABC-5',
      "product_name": 'Tangerine Haze Fresh Frozen (disabled)',
      "description": 'Tangerine Haze Fresh Frozen description',
      "live_inventory_quantity": 7,
      "active": false,
      "size_list": [{
        "product_size_name": 'Tangerine Haze Fresh Frozen',
        "price_sell": 25.5,
        "size_id": 'ABC-5-1',
        "type": 'CARTRIDGE',
        "live_inventory_quantity": 3
      }]
    }, {
      "type": 'CARTRIDGE',
      "product_id": 'ABC-6',
      "product_name": 'Tangerine Haze Fresh Frozen (disabled)',
      "description": 'Tangerine Haze Fresh Frozen description',
      "live_inventory_quantity": 7,
      "active": false,
      "size_list": [{
        "product_size_name": 'Tangerine Haze Fresh Frozen',
        "price_sell": 25.5,
        "size_id": 'ABC-6-1',
        "live_inventory_quantity": 3
      }],
      "images": {
        "cropped_image_url": 'https://cropped.jpg'
      }
    }]
  end
end
