require 'rails_helper'

describe 'API V1 Categories' do
  include Api::V1::SerializationHelper::Stores

  let(:kiosk) { create :kiosk, store: store }
  let(:store) { create :store, categories_count: 0 }

  def category_json(category)
    category.as_json(only: %i[id name order]).merge(
      'created_at' => category.created_at.iso8601(3),
      'updated_at' => category.updated_at.iso8601(3),
      'banner' => asset_json(category.banner)
    )
  end

  describe '#index' do
    let(:categories) do
      [
        create(:store_category, order: 10, store: store),
        create(:store_category, order: 30, store: store),
        create(:store_category, order: 20, store: store, banner: build(:asset))
      ]
    end
    let(:expected_categories) { categories.sort_by(&:order).map { |cat| category_json(cat) } }

    before do
      categories.each do |sc|
        # Create 2 products for each category
        create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store, store_category: sc)
        create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store, store_category: sc)
      end

      # Category without any product attached. Should not be included
      create :store_category, order: 50, store: store
      # Category attached to unpublished product. Should not be included
      create(:store_category, order: 50, store: store).tap do |sc|
        create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store, store_category: sc, status: :unpublished)
      end

      get "/api/v1/#{kiosk.id}/categories", headers: auth_headers(store)
    end

    it 'respond with categories' do
      expect(json).to have_key('categories')
      expect(json['categories'].count).to eq 3
      expect(json['categories']).to eq expected_categories
    end
  end
end
