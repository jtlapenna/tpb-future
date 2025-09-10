require 'rails_helper'

describe ProductCSVParser do
  let(:store) { create :store }
  let(:catalog) { create :catalog, store: store }
  let(:parser) { ProductCSVParser.new(file: file, store_id: store.id) }
  let(:file) { Tempfile.new('products.csv') }
  let(:rows) do
    [
      [' sku', 'name  ', '   category', 'stock', 'REG', 'OMMP'],
      [' ABC-1 ', ' Product 1 ', ' Category 1 ', '10', 100.35, 0],
      ['ABC-2', ' Product 2', 'Category 1', 8, nil, 13],
      ['ABC-3', 'Product 3 ', ' Category 2', 0, 30, '  ']
    ]
  end

  before do
    store.store_prices.create!(name: 'REG')
    store.store_prices.create!(name: 'OMMP')

    CSV.open(file, 'w') do |csv|
      rows.each { |row| csv << row }
    end
  end

  it 'create sync' do
    expect do
      parser.parse
    end.to change {
      StoreSync.count
    }.by 1
  end

  it 'created sync values when file es valid' do
    sync = parser.parse[:sync]

    expect(sync).to be
    expect(sync.store_sync_items.count).to eq 3
    expect(sync.store_sync_items[0].sku).to eq 'ABC-1'
    expect(sync.store_sync_items[0].name).to eq 'Product 1'
    expect(sync.store_sync_items[0].category).to eq 'Category 1'
    expect(sync.store_sync_items[0].stock).to eq 10
    expect(sync.store_sync_items[0].brand).to be_nil
    expect(sync.store_sync_items[0].prices.count).to eq 2
    expect(sync.store_sync_items[0].prices).to eq [
      { name: 'REG', value: 100.35 },
      { name: 'OMMP', value: 0 }
    ].map(&:stringify_keys)

    expect(sync.store_sync_items[1].prices.count).to eq 1
    expect(sync.store_sync_items[1].prices.count).to eq 1
  end

  context 'with some errors' do
    let(:rows) do
      [
        %w[sku name category stock REG OMMP],
        [' ABC-1 ', ' Product 1 ', ' Category 1 ', '-10'], # Not valid, stock is negative.
        [' ', ' Product 2', 'Category 1', 8], # Not valid, no sku.
        ['ABC-3', ' Product 3', 'Category 3', 8]
      ]
    end

    it 'created sync values when file is valid' do
      sync = parser.parse

      expect(sync[:sync]).not_to be
      expect(sync[:errors]).to be_present
      expect(sync[:errors]).to eq [
        { row: 1, messages: { stock: ['must be greater than or equal to 0'] } },
        { row: 2, messages: { sku: ["can't be blank"] } }
      ]
    end
  end

  context 'require price headers' do
    let(:rows) do
      [
        [' sku ', ' name', 'category', 'stock', 'casa', 'OMMP'],
        ['ABC-3', ' Product 3', 'Category 3', 8]
      ]
    end

    it 'fail with error' do
      sync = parser.parse

      expect(sync[:sync]).not_to be
      expect(sync[:errors]).to be_present
      expect(sync[:errors]).to eq [
        { row: 1, messages: { headers: ['Incorrect headers: casa'] } },
        { row: 1, messages: { headers: ['Missing headers: REG'] } }
      ]
    end
  end
end
