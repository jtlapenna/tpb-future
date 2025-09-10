require 'rails_helper'

describe 'API V1 Products, update_at attribute' do
  include Api::V1::SerializationHelper::Products

  let(:store) { create :store }
  let(:kiosk) { create :kiosk, store: store }
  let(:store_product) { create :store_product, store: store }
  let(:variant) { store_product.product_variant }
  let(:product) { variant.product }
  let(:expected_product) { product_json(store_product, include_attribute_values: true) }

  before do
    create :kiosk_product, kiosk: kiosk, store_product: store_product

    store_product.touch
    Timecop.travel 5.minutes.from_now
    Timecop.freeze
    last_updated_object.touch

    get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
  end

  after { Timecop.return }

  shared_examples_for 'match updated at' do
    it 'match updated_at' do
      expect(json).to have_key 'product'
      expect(json['product']['updated_at']).to eq Time.current.iso8601(3)
    end
  end

  context 'when variant is the last changed object' do
    let(:last_updated_object) { variant }

    it_should_behave_like 'match updated at'
  end

  context 'when master product is the last changed object' do
    let(:last_updated_object) { product }

    it_should_behave_like 'match updated at'
  end

  context 'when store product is the last changed object' do
    let(:last_updated_object) { store_product }

    it_should_behave_like 'match updated at'
  end
end
