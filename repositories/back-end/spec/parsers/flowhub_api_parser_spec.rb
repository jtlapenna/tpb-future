require 'rails_helper'

describe FlowhubApiParser do
  include FlowhubApiHelper

  let(:store) { create :flowhub_store, customer_type_filter: 'medCustomer' }
  let(:parser) { FlowhubApiParser.new(store_id: store.id) }
  let(:api) { double }
  let(:api_products) { [] }

  before do
    allow(api).to receive(:products).and_return(api_products, [])
    expect(Flowhub::ApiClient).to receive(:new)
      .with(
        location_id: 'xxx',
        api_key: store.api_key,
        client_id: store.api_client_id,
        auth0_client_id: store.auth0_client_id,
        auth0_client_secret: store.auth0_client_secret
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
      ENV['FLOWHUB_PREROLL_IMAGE_URL'] = nil

      sync = parser.parse[:sync]

      expect(sync).to be
      expect(sync.store_sync_items.count).to eq 9

      expect(sync.store_sync_items[0].sku).to eq '1510664'
      expect(sync.store_sync_items[0].name).to eq "Randy's Papers"
      expect(sync.store_sync_items[0].weight). to eq 0
      expect(sync.store_sync_items[0].description).to eq 'This is a template description'
      expect(sync.store_sync_items[0].size_name).to eq "Randy's Papers"
      expect(sync.store_sync_items[0].category).to eq 'Pre-Roll'
      expect(sync.store_sync_items[0].stock).to eq 41
      expect(sync.store_sync_items[0].brand).to eq 'AFG Glass'
      expect(sync.store_sync_items[0].active).to be
      expect(sync.store_sync_items[0].prices.count).to eq 1
      expect(sync.store_sync_items[0].prices).to eq [
        { name: '', value: 2.0 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[0].images).to eq({})
      expect(sync.store_sync_items[0].attributes_values).to eq([])
      expect(sync.store_sync_items[0].tags).to eq([])

      expect(sync.store_sync_items[1].sku).to eq '1510666'
      expect(sync.store_sync_items[1].name).to eq 'Glass $24'
      expect(sync.store_sync_items[1].weight). to eq 0
      expect(sync.store_sync_items[1].description).to eq nil
      expect(sync.store_sync_items[1].size_name).to eq 'Glass $24'
      expect(sync.store_sync_items[1].category).to eq 'Accessory'
      expect(sync.store_sync_items[1].stock).to eq 50
      expect(sync.store_sync_items[1].brand).to eq 'AFG Glass'
      expect(sync.store_sync_items[1].active).to be
      expect(sync.store_sync_items[1].prices.count).to eq 1
      expect(sync.store_sync_items[1].prices).to eq [
        { name: '', value: 24 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[1].images).to eq({})
      expect(sync.store_sync_items[1].attributes_values).to eq([])
      expect(sync.store_sync_items[1].tags).to eq([])

      expect(sync.store_sync_items[2].sku).to eq '1510670'
      expect(sync.store_sync_items[2].name).to eq 'Formula 420 Cleaner'
      expect(sync.store_sync_items[2].weight). to eq 0
      expect(sync.store_sync_items[2].description).to be_nil
      expect(sync.store_sync_items[2].size_name).to eq 'Formula 420 Cleaner'
      expect(sync.store_sync_items[2].category).to eq 'Accessory'
      expect(sync.store_sync_items[2].stock).to eq 49
      expect(sync.store_sync_items[2].brand).to eq 'AFG Glass'
      expect(sync.store_sync_items[2].active).to be
      expect(sync.store_sync_items[2].prices.count).to eq 1
      expect(sync.store_sync_items[2].prices).to eq [
        { name: '', value: 7.39 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[2].images).to eq({})
      expect(sync.store_sync_items[2].attributes_values).to eq([])
      expect(sync.store_sync_items[2].tags).to eq([])

      expect(sync.store_sync_items[3].sku).to eq '1513818'
      expect(sync.store_sync_items[3].name).to eq 'Electric Lemon x Brian Berry Cough (1000mg)'
      expect(sync.store_sync_items[3].weight).to eq 1000
      expect(sync.store_sync_items[3].description).to eq nil
      expect(sync.store_sync_items[3].size_name).to eq 'Electric Lemon x Brian Berry Cough (1000mg)'
      expect(sync.store_sync_items[3].category).to eq 'Flower'
      expect(sync.store_sync_items[3].stock).to eq 0
      expect(sync.store_sync_items[3].brand).to eq 'Flowhub Colorado'
      expect(sync.store_sync_items[3].active).to be
      expect(sync.store_sync_items[3].prices.count).to eq 1
      expect(sync.store_sync_items[3].prices).to eq [
        { name: '', value: 10.0 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[3].attributes_values).to match_array [
        { 'name' => 'THC', 'value' => '14.75 - 28.31 %R' },
        { 'name' => 'TYPE', 'value' => 'sativa' }
      ]
      expect(sync.store_sync_items[3].tags).to eq([])

      expect(sync.store_sync_items[4].sku).to eq '2510664'
      expect(sync.store_sync_items[4].name).to eq "Randy's Papers"
      expect(sync.store_sync_items[4].weight).to eq 0
      expect(sync.store_sync_items[4].description).to eq 'This is a Pre-Roll'
      expect(sync.store_sync_items[4].size_name).to eq "Randy's Papers"
      expect(sync.store_sync_items[4].category).to eq 'Pre-Roll'
      expect(sync.store_sync_items[4].stock).to eq 41
      expect(sync.store_sync_items[4].brand).to eq 'AFG Glass'
      expect(sync.store_sync_items[4].active).to be
      expect(sync.store_sync_items[4].prices.count).to eq 1
      expect(sync.store_sync_items[4].prices).to eq [
        { name: '', value: 2.0 }
      ].map(&:stringify_keys)
      expect(sync.store_sync_items[4].images).to eq(
        'primary' => 'http://prerol/picture.png',
        'thumb' => 'http://prerol/picture.png'
      )
      expect(sync.store_sync_items[4].attributes_values).to eq([])
      expect(sync.store_sync_items[4].tags).to eq([])

      expect(sync.store_sync_items[5].sku).to eq '6946433'
      expect(sync.store_sync_items[5].name).to eq '(Scent) Lotion 1:1 THC/CBD 100mg'
      expect(sync.store_sync_items[5].weight).to eq 100

      expect(sync.store_sync_items[6].sku).to eq '6761208'
      expect(sync.store_sync_items[6].name).to eq 'Dark Chocolate 10PK 50mg THC'
      expect(sync.store_sync_items[6].weight).to eq 50

      expect(sync.store_sync_items[7].sku).to eq '6761247'
      expect(sync.store_sync_items[7].name).to eq 'Tincture 1000mg Mint'
      expect(sync.store_sync_items[7].weight).to eq 1000
    end

    it 'and it is a concentrate' do
      sync = parser.parse[:sync]

      expect(sync.store_sync_items[8].sku).to eq '6761248'
      expect(sync.store_sync_items[8].name).to eq 'AP FV x BK x CK Ambrosia 1g'
      expect(sync.store_sync_items[8].category).to eq 'Concentrate'
      expect(sync.store_sync_items[8].weight).to eq 1000
    end

    it 'override preroll images when FLOWHUB_PREROLL_IMAGE_URL is defined' do
      image_url = 'http://pre-roll/sample/image.jpg'

      ENV['FLOWHUB_PREROLL_IMAGE_URL'] = image_url

      sync = parser.parse[:sync]

      expect(sync).to be
      expect(sync.store_sync_items.count).to eq 9

      expect(sync.store_sync_items[0].images).to eq('primary' => image_url, 'thumb' => image_url)
      expect(sync.store_sync_items[1].images).to eq({})
      expect(sync.store_sync_items[2].images).to eq({})
      expect(sync.store_sync_items[3].images).to eq({})
      expect(sync.store_sync_items[4].images).to eq('primary' => image_url, 'thumb' => image_url)
    end

    context 'when store has no customer filter' do
      let(:store) { create :flowhub_store }

      it 'create sync itenms for all products' do
        sync = parser.parse[:sync]

        expect(sync).to be
        expect(sync.store_sync_items.count).to eq 10
      end
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
    [
      flowhub_products[0],
      flowhub_products[1],
      flowhub_products[2],
      flowhub_products[4],
      flowhub_products[6],
      flowhub_products[7],
      flowhub_products[8],
      flowhub_products[9],
      flowhub_products[10],
      flowhub_products[11]
    ]
  end

  def product_with_errors_json
    [
      flowhub_products[0],
      flowhub_products[3], # Not valid, stock is negative.
      flowhub_products[5], # Not valid, no sku.
      flowhub_products[1]
    ]
  end
end
