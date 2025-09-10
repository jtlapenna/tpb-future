require 'rails_helper'

describe 'Kiosk Products API' do
  include SerializationHelper::Stores

  let(:user) { create :user }
  let(:store) { create :store }
  let(:kiosk) { create :kiosk, store: store }

  context '#index' do
    let(:products) { KioskProduct.where(kiosk_id: kiosk).order(id: :desc) }
    let(:expected_products) { products.map { |p| kiosk_product_minimal_json(p) } }

    before do
      create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
      create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
      create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
      create :kiosk_product

      get kiosk_kiosk_products_path(kiosk), headers: auth_headers(user)
    end

    it 'respond with products' do
      expect(json).to have_key('kiosk_products')
      expect(json['kiosk_products'].count).to eq 3
      expect(json['kiosk_products']).to eq expected_products
    end
  end

  context '#index#compact' do
    let(:products) { KioskProduct.where(kiosk_id: kiosk).order(id: :desc) }
    let(:expected_products) { products.map { |p| kiosk_product_compact_json(p) } }

    before do
      create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
      create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
      create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
      create :kiosk_product

      get kiosk_kiosk_products_path(kiosk), headers: auth_headers(user), params: { only_id: true }
    end

    it 'respond with products' do
      expect(json).to have_key('kiosk_products')
      expect(json['kiosk_products'].count).to eq 3
      expect(json['kiosk_products']).to eq expected_products
    end
  end

  context '#index#sort' do
    let(:products) { KioskProduct.all.sort_by(&:name) }
    let(:expected_products) { products.map { |p| kiosk_product_minimal_json(p) } }

    before do
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, name: 'Store Product 3', stock: 1, store: store)
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, name: 'Store Product 1', stock: 2, store: store)
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, name: 'Store Product 2', stock: 4, store: store)
    end

    it 'respond with sorted products by name' do
      get kiosk_kiosk_products_path(kiosk), params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)

      expect(json).to have_key('kiosk_products')
      expect(json['kiosk_products'].count).to eq 3
      expect(json['kiosk_products']).to eq expected_products
    end

    it 'respond with sorted products by stock' do
      get kiosk_kiosk_products_path(kiosk), params: { sort_by: 'stock', sort_direction: 'asc' }, headers: auth_headers(user)

      expect(json).to have_key('kiosk_products')
      expect(json['kiosk_products'].count).to eq 3
      expect(json['kiosk_products']).to eq expected_products.sort_by { |prod| prod['store_product']['stock'] }
    end
  end

  context '#index#filter' do
    let(:store) { create :store, categories_count: 2 }
    let(:store_2) { create :store, categories_count: 1 }
    let(:brands) { create_list :brand, 2 }
    let(:variant) { create :product_variant, brand: brands[0], product: product }
    let(:variant_1) { create :product_variant, brand: brands[1], product: product }
    let(:product) { create :product }
    let(:category_1) { store.store_categories.first }
    let(:category_2) { store.store_categories.last }
    let(:category_3) { store_2.store_categories.last }
    let!(:products) do
      [
        create(:store_product, name: 'Product 1', store_category: category_1, product_variant: variant),
        create(:store_product, name: 'Product 2', store_category: category_1, product_variant: variant),
        create(:store_product, name: 'Product 4', store_category: category_3),
        create(:store_product, name: 'Product 3', store_category: category_2, tag_list: ['tag 1']),
        create(:store_product, name: 'Product 5', store_category: category_2, product_variant: variant, brand: brands[1]),
        create(:store_product, name: 'Product 6', store_category: category_2, product_variant: variant_1, brand: brands[0])
      ]
    end

    before do
      products.each { |p| create :kiosk_product, kiosk: kiosk, store_product: p }
      get kiosk_kiosk_products_path(kiosk), params: params, headers: auth_headers(user)
    end

    context 'by category' do
      let!(:expected_products) do
        [products[0], products[1]].map { |c| kiosk_product_minimal_json(c.kiosk_products.first) }
      end
      let(:params) { { store_category_id: category_1.id, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('kiosk_products')
        expect(json['kiosk_products'].count).to eq 2
        expect(json['kiosk_products']).to eq expected_products
      end
    end

    context 'by brand' do
      let!(:expected_products) { [products[0], products[1], products[5]].map { |c| kiosk_product_minimal_json(c.kiosk_products.first) } }
      let(:params) { { brand_id: brands[0].id, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('kiosk_products')
        expect(json['kiosk_products'].count).to eq 3
        expect(json['kiosk_products']).to eq expected_products
      end
    end

    context 'by brand in catalog product' do
      let!(:expected_products) { [products[4]].map { |c| kiosk_product_minimal_json(c.kiosk_products.first) } }
      let(:params) { { brand_id: brands[1].id, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('kiosk_products')
        expect(json['kiosk_products'].count).to eq 1
        expect(json['kiosk_products']).to eq expected_products
      end
    end

    context 'by product' do
      let!(:expected_products) { [products[0], products[1], products[4], products[5]].map { |c| kiosk_product_minimal_json(c.kiosk_products.first) } }
      let(:params) { { product_id: product.id, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('kiosk_products')
        expect(json['kiosk_products'].count).to eq 4
        expect(json['kiosk_products']).to eq expected_products
      end
    end

    context 'by product name' do
      let!(:expected_products) { [products[0]].map { |c| kiosk_product_minimal_json(c.kiosk_products.first) } }
      let(:params) { { name: products[0].name, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('kiosk_products')
        expect(json['kiosk_products'].count).to eq 1
        expect(json['kiosk_products']).to eq expected_products
      end
    end

    context 'by tag' do
      let(:expected_products) { [kiosk_product_minimal_json(products[3].kiosk_products.first)] }
      let(:params) { { tag: 'tag 1' } }

      it 'respond with filtered products' do
        expect(json).to have_key('kiosk_products')
        expect(json['kiosk_products'].count).to eq 1
        expect(json['kiosk_products']).to eq expected_products
      end

      context 'include variant tags in the search' do
        let(:product) { create :product, tag_list: ['tag 1'] }
        let(:variant) { create :product_variant, product: product }
        let(:expected_products) { (products[0..1] + products[3..5]).reverse.map { |p| kiosk_product_minimal_json(p.kiosk_products.first) } }
        let(:params) { { tag: 'tag 1' } }

        it 'respond with filtered products' do
          expect(json).to have_key('kiosk_products')
          expect(json['kiosk_products'].count).to eq 5
          expect(json['kiosk_products']).to eq expected_products
        end
      end

      context 'include product tags in the search' do
        let(:variant) { create :product_variant, tag_list: ['tag 1'] }
        let(:expected_products) { (products[0..1] + products[3..4]).reverse.map { |p| kiosk_product_minimal_json(p.kiosk_products.first) } }
        let(:params) { { tag: 'tag 1' } }

        it 'respond with filtered products' do
          expect(json).to have_key('kiosk_products')
          expect(json['kiosk_products'].count).to eq 4
          expect(json['kiosk_products']).to eq expected_products
        end
      end
    end
  end

  it_behaves_like 'paginated resource', KioskProduct do
    let(:skip_creation) { true }
    let(:url_params) { { store_id: store.id } }
    let(:path) { kiosk_kiosk_products_path(kiosk) }

    before do
      15.times do
        create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store)
      end
    end
  end

  context '#create' do
    let(:store) { category.store }
    let(:variant) { create :product_variant }
    let(:category) { create :store_category }
    let!(:store_product1) { create :store_product, store: store }
    let!(:store_product2) { create :store_product, store: store }
    let(:products) { kiosk.kiosk_products }
    let(:params) do
      {
        kiosk_products: [
          { store_product_id: store_product1.id, featured: true },
          { store_product_id: store_product2.id }
        ]
      }
    end
    let(:missing_name_params) do
      {
        kiosk_products: [
          { store_product_id: store_product1.id },
          { store_product_id: 'not_exists' }
        ]
      }
    end

    it 'create product' do
      expect do
        post kiosk_kiosk_products_path(kiosk), params: params, headers: auth_headers(user)
      end.to change {
        KioskProduct.count
      }.by 2

      expect(kiosk.kiosk_products.where(featured: true).count).to eq 1
    end

    it 'created product values' do
      post kiosk_kiosk_products_path(kiosk), params: params, headers: auth_headers(user)

      expect(products.map(&:store_product)).to match_array [store_product1, store_product2]
    end

    it 'return errors' do
      expect do
        post kiosk_kiosk_products_path(kiosk), params: missing_name_params, headers: auth_headers(user)
      end.not_to change { KioskProduct.count }

      expect(json).to have_key('errors')
      expect(json['errors'].count).to eq 1
      expect(json['errors'][0]).to have_key('store_product')
      expect(json['errors'][0]).to eq('store_product' => ['must exist'])
    end
  end

  context '#update' do
    let(:params) { { id: product.id, kiosk_product: { featured: true } } }
    let(:product) { create :kiosk_product, featured: false, kiosk: kiosk }

    it 'update product' do
      put kiosk_kiosk_product_path(kiosk, product), params: params, headers: auth_headers(user)

      expect(product.reload.featured).to be_truthy
    end

    it 'return updated product' do
      put kiosk_kiosk_product_path(kiosk, product), params: params, headers: auth_headers(user)

      expect(json).to have_key('kiosk_product')
      expect(json['kiosk_product']).to eq kiosk_product_json(product.reload)
    end
  end

  context '#show' do
    let(:params) { { kiosk_id: kiosk.id, id: product.id } }
    let(:store_product) { create :store_product, store: store }
    let(:product) { create :kiosk_product, kiosk: kiosk, store_product: store_product }

    it 'return product' do
      get kiosk_kiosk_product_path(kiosk.id, product.id), params: params, headers: auth_headers(user)

      expect(json).to have_key('kiosk_product')
      expect(json['kiosk_product']).to eq kiosk_product_json(product.reload)
    end
  end

  context '#destroy' do
    let(:store_product) { create :store_product, store: store }
    let!(:product) { create :kiosk_product, kiosk: kiosk, store_product: store_product }

    it 'destroy product' do
      expect do
        delete kiosk_kiosk_product_path(kiosk, product), headers: auth_headers(user)
      end.to change { KioskProduct.count }.by -1
    end
  end

  def product_search_json(product)
    p_json = product.as_json(only: %i[id featured])
    p_json['store_product'] = {}
    p_json['store_product']['brand'] = product.brand.as_json(only: %i[id name])
    p_json['store_product']['name'] = product.name_for_catalog
    p_json['store_product']['product_variant'] = product_variant_search_json(product.product_variant)
    p_json['store_product']['stock'] = product.stock
    p_json['store_product']['status'] = product.status
    p_json['store_product']['store_category'] = category_search_json(product.store_category)
    p_json['store_product']['sku'] = product.sku
    p_json['store_product']['id'] = product.store_product_id

    p_json
  end

  def category_search_json(category)
    category.as_json(only: %i[id name])
  end

  def product_variant_search_json(product_variant)
    pv_json = product_variant.as_json(only: %i[id name product_id]) if product_variant
    pv_json['name'] = product_variant.name_for_product if product_variant
    pv_json['brand'] = product_variant.brand.as_json(only: %i[id name]) if product_variant.brand
    pv_json
  end

  context '#search' do
    let(:kiosk) { create :kiosk, store: store }
    let(:store) { category.store }
    let(:category) { create :store_category }
    let(:master_product) { create :product, name: 'AProduct 1', tag_list: ['tag 1'] }
    let(:master_product2) { create :product, name: 'AProduct 2' }
    let(:variants) do
      [
        create(:product_variant, name: 'AProduct 2', tag_list: ['tag 1']),
        create(:product_variant, name: 'AProduct 3'),
        create(:product_variant, name: nil, product: master_product)
      ]
    end
    let!(:products) do
      [
        create(:store_product, name: 'AProduct', product_variant: variants[2], store_category: category, tag_list: ['tag 1']),
        create(:store_product, name: nil, product_variant: variants[2], store_category: category), # AProduct 1
        create(:store_product, name: nil, product_variant: variants[0], store_category: category), # AProduct 2
        create(:store_product, name: nil, product_variant: variants[1], store_category: category) # AProduct 3
      ]
    end
    let(:expected_products) { kiosk_products.map { |p| product_search_json(p) } }
    let!(:kiosk_products) { products.map { |sp| create :kiosk_product, store_product: sp, kiosk: kiosk } }

    before do
      create :store_product, name: 'new name', product_variant: variants[1], store_category: category
      create :store_product, name: 'BProduct 1', product_variant: variants[0], store_category: category
      create :product_variant, name: 'BProduct 1', product: master_product2
      create :product_variant, name: 'CProduct 4'
    end

    context 'filter by name' do
      before do
        get search_kiosk_kiosk_products_path(kiosk), params: { name: 'aproduct' }, headers: auth_headers(user)
      end

      it 'respond with filtered products' do
        expect(json).to have_key('kiosk_products')
        expect(json).not_to have_key('meta')
        expect(json['kiosk_products'].count).to eq 4
        expect(json['kiosk_products'][0]).to eq expected_products[0]
      end
    end
  end
end
