require 'rails_helper'

describe 'API V1 Brands' do
  let(:kiosk) { create :kiosk, store: store }
  let(:store) { create :store, categories_count: 1 }

  def brand_json(brand)
    includes = { logo: { only: %i[id url] } }
    b_json = brand.as_json(only: %i[id name description], include: includes).merge(
      'created_at' => brand.created_at.iso8601(3),
      'updated_at' => brand.updated_at.iso8601(3)
    )

    if brand.logo
      b_json['logo']['created_at'] = brand.logo.created_at.iso8601(3)
      b_json['logo']['updated_at'] = brand.logo.updated_at.iso8601(3)
    else
      b_json['logo'] = nil
    end

    b_json['total_products'] = kiosk.store_products
                                    .joins(:product_variant)
                                    .where(product_variants: { brand_id: brand.id }).count

    b_json
  end

  describe '#index' do
    let(:other_kiosk) { create :kiosk, store: store }
    let(:brands) { create_list :brand, 3 }
    let(:brands_in_catalog) { brands.take(2) }
    let(:expected_brands) { brands_in_catalog.map { |cat| brand_json(cat) } }
    let(:categories) { store.store_categories }

    before do
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, product_variant: create(:product_variant, brand: brands_in_catalog[0]), store_category: categories.first, stock: 1)
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, product_variant: create(:product_variant, brand: brands_in_catalog[1]), store_category: categories.first, stock: 1)
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, product_variant: create(:product_variant, brand: brands_in_catalog[1]), store_category: categories.first, stock: 1)
      # an extra store_product from other store, should not be included in the products count
      create(:store, categories_count: 1).store_categories.first.store_products << build(:store_product, product_variant: create(:product_variant, brand: brands_in_catalog[1]), stock: 2)
      # an extra store_product from other kiosk, should not be included in the products count
      create :kiosk_product, kiosk: other_kiosk, store_product:
        create(:store_product, product_variant: create(:product_variant, brand: brands_in_catalog[1]), store_category: categories.first, stock: 1)
      # brand with only store_product from other kiosk, should not be included in the brands list
      create :kiosk_product, kiosk: other_kiosk, store_product:
        create(:store_product, product_variant: create(:product_variant, brand: brands[2]), store_category: categories.first, stock: 1)
    end

    context 'without any params' do
      before do
        get "/api/v1/#{kiosk.id}/brands", headers: auth_headers(store)
      end

      it 'respond with brands associated to the catalog' do
        expect(json).to have_key('brands')
        expect(json['brands'].count).to eq 2
        expect(json['brands']).to match_array expected_brands
        expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 2, 'total_pages' => 1)
      end

      it 'total store products count' do
        expect(json['brands'][0]['total_products']).to eq 2
        expect(json['brands'][1]['total_products']).to eq 1
      end
    end

    context 'ordering by name' do
      before do
        get "/api/v1/#{kiosk.id}/brands?sort_by=name&sort_direction=asc", headers: auth_headers(store)
      end

      it 'respond with the sorted list' do
        expect(json).to have_key('brands')
        expect(json['brands']).to eq expected_brands.sort_by { |pr| pr['name'] }
      end
    end

    context 'accessing to another page' do
      before do
        get "/api/v1/#{kiosk.id}/brands?sort_by=name&sort_direction=asc&per_page=1&page=2", headers: auth_headers(store)
      end

      it 'respond only with the product on that page' do
        expect(json).to have_key('brands')
        expect(json['brands'].count).to eq 1
        expect(json['brands'][0]['id']).to eq expected_brands.max_by { |pr| pr['name'] }['id']
      end
    end

    context 'when all products are out of stock' do
      before do
        create :kiosk_product, kiosk: kiosk, store_product:
          create(:store_product, product_variant: create(:product_variant, brand: brands[2]), store_category: categories.first, stock: 0)

        get "/api/v1/#{kiosk.id}/brands", headers: auth_headers(store)
      end

      it 'respond only with the brands with product stock > 0' do
        expect(json).to have_key('brands')
        expect(json['brands'].count).to eq 2
      end
    end

    context 'when some products are unpublished' do
      before do
        StoreProduct.where(id: StoreProduct.order(id: :asc).offset(1).limit(2)).update_all(status: 'unpublished')

        get "/api/v1/#{kiosk.id}/brands", headers: auth_headers(store)
      end

      it 'respond with brands with at least one product published' do
        expect(json).to have_key('brands')
        expect(json['brands'].count).to eq 1
        expect(json['brands']).to match_array [brand_json(brands_in_catalog[0])]
        expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 1, 'total_pages' => 1)
      end

      it 'total store products condisder published' do
        expect(json['brands'][0]['total_products']).to eq 1
      end
    end

    context 'when some products are out of stock' do
      let(:brands_in_catalog) { brands.take(3) }

      before do
        create :kiosk_product, kiosk: kiosk, store_product:
          create(:store_product, product_variant: create(:product_variant, brand: brands_in_catalog[2]), store_category: categories.first, stock: 0)
        create :kiosk_product, kiosk: kiosk, store_product:
          create(:store_product, product_variant: create(:product_variant, brand: brands_in_catalog[2]), store_category: categories.first, stock: 1)

        get "/api/v1/#{kiosk.id}/brands", headers: auth_headers(store)
      end

      it 'include brand' do
        expect(json).to have_key('brands')
        expect(json['brands'].count).to eq 3
        expect(json['brands']).to match_array expected_brands
      end

      it 'count all products' do
        expect(json['brands'][0]['total_products']).to eq 2
        expect(json['brands'][1]['total_products']).to eq 2
        expect(json['brands'][2]['total_products']).to eq 1
      end
    end
  end
end
