require 'rails_helper'

describe 'Store Products API' do
  include SerializationHelper::Stores

  let(:user) { create :user }

  context '#index' do
    let(:store) { create :store }
    let(:products) { StoreProduct.all.order(id: :desc) }
    let(:expected_products) { products.map { |p| store_product_json(p) } }

    before do
      create_list :store_product, 3, store: store
      get store_store_products_path(store), headers: auth_headers(user)
    end

    it 'respond with products' do
      expect(json).to have_key('store_products')
      expect(json['store_products'].count).to eq 3
      expect(json['store_products']).to eq expected_products
    end
  end

  context '#index#sort' do
    let(:store) { create :store }
    let(:products) { StoreProduct.all.order(name: :asc) }
    let(:expected_products) { products.map { |p| store_product_json(p) } }

    before do
      create :store_product, name: 'Store Product 3', stock: 1, store: store
      create :store_product, name: 'Store Product 1', stock: 2, store: store
      create :store_product, name: 'Store Product 2', stock: 4, store: store
    end

    it 'respond with sorted products by name' do
      get store_store_products_path(products[0].store_id), params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)

      expect(json).to have_key('store_products')
      expect(json['store_products'].count).to eq 3
      expect(json['store_products']).to eq expected_products
    end

    it 'respond with sorted products by stock' do
      get store_store_products_path(products[0].store_id), params: { sort_by: 'stock', sort_direction: 'asc' }, headers: auth_headers(user)

      expect(json).to have_key('store_products')
      expect(json['store_products'].count).to eq 3
      expect(json['store_products']).to eq expected_products.sort_by { |prod| prod['stock'] }
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
      get store_store_products_path(store.id), params: params, headers: auth_headers(user)
    end

    context 'by category' do
      let!(:expected_products) { [products[0], products[1]].map { |c| store_product_json(c) } }
      let(:params) { { store_category_id: category_1.id, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json['store_products'].count).to eq 2
        expect(json['store_products']).to eq expected_products
      end
    end

    context 'by brand' do
      let!(:expected_products) { [products[0], products[1], products[5]].map { |c| store_product_json(c) } }
      let(:params) { { brand_id: brands[0].id, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json['store_products'].count).to eq 3
        expect(json['store_products']).to eq expected_products
      end
    end

    context 'by brand in catalog product' do
      let!(:expected_products) { [products[4]].map { |c| store_product_json(c) } }
      let(:params) { { brand_id: brands[1].id, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json['store_products'].count).to eq 1
        expect(json['store_products']).to eq expected_products
      end
    end

    context 'by product' do
      let!(:expected_products) { [products[0], products[1], products[4], products[5]].map { |c| store_product_json(c) } }
      let(:params) { { product_id: product.id, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json['store_products'].count).to eq 4
        expect(json['store_products']).to eq expected_products
      end
    end

    context 'by product name' do
      let!(:expected_products) { [products[0]].map { |c| store_product_json(c) } }
      let(:params) { { name: products[0].name, sort_by: 'name', sort_direction: 'asc' } }

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json['store_products'].count).to eq 1
        expect(json['store_products']).to eq expected_products
      end
    end

    context 'by tag' do
      let(:expected_products) { [store_product_json(products[3])] }
      let(:params) { { tag: 'tag 1' } }

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json['store_products'].count).to eq 1
        expect(json['store_products']).to eq expected_products
      end

      context 'include variant tags in the search' do
        let(:product) { create :product, tag_list: ['tag 1'] }
        let(:variant) { create :product_variant, product: product }
        let(:expected_products) { (products[0..1] + products[3..5]).reverse.map { |p| store_product_json(p) } }
        let(:params) { { tag: 'tag 1' } }

        it 'respond with filtered products' do
          expect(json).to have_key('store_products')
          expect(json['store_products'].count).to eq 5
          expect(json['store_products']).to eq expected_products
        end
      end

      context 'include product tags in the search' do
        let(:variant) { create :product_variant, tag_list: ['tag 1'] }
        let(:expected_products) { (products[0..1] + products[3..4]).reverse.map { |p| store_product_json(p) } }
        let(:params) { { tag: 'tag 1' } }

        it 'respond with filtered products' do
          expect(json).to have_key('store_products')
          expect(json['store_products'].count).to eq 4
          expect(json['store_products']).to eq expected_products
        end
      end
    end
  end

  context 'index#full_text_search' do
    let(:expected_products) { [] }
    let(:store) { create :store }

    context 'when algolia is enabled' do
      before do
        prods = double
        allow(prods).to receive(:raw_answer).and_return('nbHits' => 0)
        allow(prods).to receive(:count).and_return 0
        allow(prods).to receive(:first).and_return(StoreProduct.all)

        expect(StoreProduct).to receive(:search).and_return(prods)
        get store_store_products_path(store.id), params: { q: 'product' }, headers: auth_headers(user)
      end

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json['store_products'].count).to eq 0
        expect(json['store_products']).to eq expected_products
      end

      it 'pagination' do
        expect(json).to have_key('meta')
        expect(json['meta']).to eq(
          'current_page' => 1,
          'next_page' => nil,
          'prev_page' => nil,
          'total_count' => 0,
          'total_pages' => 0
        )
      end
    end

    context 'when algolia is disabled' do
      let(:expected_products) { [] }

      before { ENV['ALGOLIASEARCH_DISABLED'] = 'true' }

      before { get store_store_products_path(store.id), params: { q: 'product' }, headers: auth_headers(user) }

      it "don't use algolia" do
        expect(StoreProduct).not_to receive(:search)
      end

      it 'fallback to name like' do
        expect(StoreProduct).not_to receive(:name_like)
      end

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json['store_products'].count).to eq 0
        expect(json['store_products']).to eq expected_products
      end
    end
  end

  it_behaves_like 'paginated resource', StoreProduct do
    let(:skip_creation) { true }
    let(:store) { create :store }
    let(:url_params) { { store_id: store.id } }

    before do
      create_list :store_product, 15, store: store
    end
  end

  context '#create' do
    let(:store) { category.store }
    let(:variant) { create :product_variant }
    let(:category) { create :store_category }
    let(:product) { StoreProduct.last }
    let(:params) do
      {
        store_product: {
          name: 'Store Product 1', store_category_id: category.id,
          product_variant_id: variant.id, tag_list: 'tag 2, tag 1',
          description: 'description', stock: 10, sku: '12345678', override_tags: true,
          video_attributes: { id: nil, url: 'http://youtube.com' }, status: :published
        }
      }
    end
    let(:missing_name_params) { { store_product: { store_category_id: category.id, sku: '1234' } } }

    it 'create product' do
      expect do
        post store_store_products_path(store.id), params: params, headers: auth_headers(user)
      end.to change {
        StoreProduct.count
      }.by 1
    end

    it 'created product values' do
      post store_store_products_path(store.id), params: params, headers: auth_headers(user)

      expect(product).to be
      expect(product).to be_published
      expect(product.name).to eq 'Store Product 1'
      expect(product.sku).to eq '12345678'
      expect(product.video.url).to eq 'http://youtube.com'
      expect(product.description).to eq 'description'
      expect(product.product_variant_id).to eq variant.id
      expect(product.store_category_id).to eq category.id
      expect(product.tags.count).to eq 2
      expect(product.stock).to eq 10
      expect(product.tag_list).to match_array ['tag 1', 'tag 2']
      expect(product.override_tags).to be
    end

    it 'respond with product' do
      post store_store_products_path(store.id), params: params, headers: auth_headers(user)

      expect(json).to have_key('store_product')
      json['store_product']['tag_list'].sort!
      expect(json['store_product']).to eq store_product_json(product)
    end

    it 'assign default image' do
      image = create :image, imageable: variant.product
      variant.images << image
      post store_store_products_path(store.id), params: params, headers: auth_headers(user)

      expect(product.reload.images.count).to eq 1
      expect(product.primary_image).to be
      expect(product.thumb_image).to be
      expect(product.images.first.url).to eq image.url
    end

    it 'return errors' do
      post store_store_products_path(store.id), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('product_variant')
      expect(json['errors']).to eq('product_variant' => ['must exist'])
    end

    context 'product price' do
      let(:params) do
        {
          store_product: {
            name: 'Store Product 1', store_category_id: category.id,
            product_variant_id: variant.id, sku: '12345678',
            product_values_attributes: [
              { name: 'price 1', value: 23.5 },
              { name: '', value: 36.78 }
            ]
          }
        }
      end

      it 'create product values' do
        expect do
          post store_store_products_path(store.id), params: params, headers: auth_headers(user)
        end.to change {
          ProductValue.count
        }.from(0).to(2)

        expect(product.product_values.count).to eq 2
        prices = product.product_values.map { |pv| { name: pv.name, value: pv.value.to_f } }
        expect(prices).to match_array([
                                        { name: 'price 1', value: 23.5 },
                                        { name: '', value: 36.78 }
                                      ])
      end

      it 'respond with product' do
        post store_store_products_path(store.id), params: params, headers: auth_headers(user)

        expect(json).to have_key('store_product')
        expect(json['store_product']).to eq store_product_json(product)
      end
    end

    context 'with images' do
      let(:image) { create :image }
      let(:variant) { create :product_variant, product: image.imageable }
      let(:params) do
        {
          store_product: {
            name: 'Store Product 1', store_category_id: category.id,
            product_variant_id: variant.id,
            image_ids: [image.id],
            primary_image_id: image.id,
            sku: '12345678'
          }
        }
      end

      before do
        variant.images << image
      end

      it 'create images' do
        post store_store_products_path(store.id), params: params, headers: auth_headers(user)

        expect(product).to be
        expect(product.images.count).to eq 1
        expect(product.primary_image).to be
        expect(product.thumb_image).to be
      end
    end

    context 'with own images' do
      let(:params) do
        {
          store_product: {
            name: 'Store Product 1',
            store_category_id: category.id,
            product_variant_id: variant.id,
            own_images_attributes: [{ url: 'xxxx' }, { url: 'yyyy' }],
            sku: '12345678'
          }
        }
      end

      it 'accept url as main image' do
        params[:store_product][:primary_image_url] = 'xxxx'

        post store_store_products_path(store), params: params, headers: auth_headers(user)

        expect(product).to be
        expect(product.primary_image).to be
        expect(product.primary_image.url).to eq 'xxxx'
      end

      it 'accept url as thumb image' do
        params[:store_product][:thumb_image_url] = 'yyyy'

        post store_store_products_path(store), params: params, headers: auth_headers(user)

        expect(product).to be
        expect(product.thumb_image).to be
        expect(product.thumb_image.url).to eq 'yyyy'
      end

      it 'create images' do
        post store_store_products_path(store), params: params, headers: auth_headers(user)

        expect(product).to be
        expect(product.own_images.count).to eq 2
      end
    end

    context 'with attributes' do
      let(:group) { create :attribute_group, name: 'MOODS' }
      let(:group_attribute) { create :attribute_def, name: 'Relaxed', attribute_group: group }
      let(:attribute) { create :attribute_def, name: 'THC' }
      let(:params) do
        {
          store_product: {
            name: 'Product 1',
            product_variant_id: variant.id,
            sku: 'A-123',
            store_category_id: category.id,
            attribute_values_attributes: [
              { attribute_def_id: group_attribute.id, value: '0.65' },
              { attribute_def_id: attribute.id, value: '0.90' }
            ]
          }
        }
      end

      it 'create attributes values' do
        post store_store_products_path(store.id), params: params, headers: auth_headers(user)

        expect(product).to be
        expect(product.attribute_values.count).to eq 2
        expect(product.attribute_values.find_by(attribute_def_id: group_attribute.id)).to be
        expect(product.attribute_values.find_by(attribute_def_id: attribute.id)).to be
      end
    end
  end

  context '#update' do
    let(:params) { { id: product.id, store_product: { name: 'new name', tag_list: 'tag 1, tag 3' } } }
    let(:product) { create :store_product, name: 'Store Product', sku: '1234' }
    let(:price_1) { build(:product_value, name: 'price 1', value: 26.89) }
    let(:price_2) { build(:product_value, name: 'price 1', value: 26.89) }

    it 'update product' do
      put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

      expect(product.reload.name).to eq 'new name'
      expect(product.tags.count).to eq 2
      expect(product.tag_list).to match_array ['tag 1', 'tag 3']
    end

    it 'return updated product' do
      put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

      expect(json).to have_key('store_product')
      json['store_product']['tag_list'].sort!
      expect(json['store_product']).to eq store_product_json(product.reload)
    end

    context 'sku' do
      let(:params) { { id: product.id, store_product: { sku: '12345' } } }

      context "client can't update sku" do
        let(:user) { create :user, client: create(:client) }

        it 'do not change sku' do
          expect do
            put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)
          end.not_to change {
            product.reload.sku
          }
        end
      end

      it 'admin can change sku' do
        expect do
          put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)
        end.to change {
          product.reload.sku
        }.from('1234').to '12345'
      end
    end

    context 'product price' do
      let(:params) do
        {
          store_product: {
            id: product.id,
            product_values_attributes: [
              { id: product.product_values.first.id, _destroy: true },
              { id: product.product_values.last.id, name: 'price 2', value: 31.22 },
              { name: 'price 1', value: 36.78 }
            ]
          }
        }
      end

      before do
        product.product_values << price_1
        product.product_values << price_2
      end

      it 'create/destroy/update product values' do
        expect do
          put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)
        end.not_to change {
          ProductValue.count
        }

        expect(product.product_values.count).to eq 2

        prices = product.reload.product_values.map { |pv| { name: pv.name, value: pv.value.to_f } }
        expect(prices).to match_array([
                                        { name: 'price 1', value: 36.78 },
                                        { name: 'price 2', value: 31.22 }
                                      ])
      end
    end

    context 'with images' do
      let(:image) { create :image }
      let(:another_image) { create :image, imageable: image.imageable }
      let(:variant) { create :product_variant, product: image.imageable }
      let(:product) { create :store_product, product_variant: variant }
      let(:params) do
        {
          store_product: {
            id: product.id,
            image_ids: [image.id, another_image.id],
            primary_image_id: another_image.id,
            thumb_image_id: another_image.id
          }
        }
      end

      before do
        variant.images << image
        variant.reload.images << another_image
      end

      it 'create images' do
        put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

        expect(product.reload.images.count).to eq 2
        expect(product.image_ids).to match_array [image.id, another_image.id]
        expect(product.primary_image).to eq another_image
        expect(product.thumb_image).to eq another_image
      end

      context 'ensure primary/thumb images' do
        let(:params) do
          { store_product: { id: product.id, image_ids: [image.id, another_image.id] } }
        end

        it 'first image is the primary' do
          put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

          expect(product.reload.images.count).to eq 2
          expect(product.primary_image).to eq image
          expect(product.thumb_image).to eq image
        end
      end
    end

    context 'with own images' do
      let(:params) do
        {
          store_product: {
            id: product.id,
            own_images_attributes: [{ id: @image.id, _destroy: true }, { url: 'zzzzzz' }]
          }
        }
      end

      before do
        @image = create :image, imageable: product, url: 'xxxxxx'
        create :image, imageable: product, url: 'yyyyyy'
      end

      it 'create new image, destroy requested images' do
        put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

        expect(product).to be
        expect(product.own_images.count).to eq 2
        expect(product.own_images.map(&:url)).to match_array %w[yyyyyy zzzzzz]
      end

      it 'accept url as main image' do
        params[:store_product][:primary_image_url] = 'zzzzzz'

        put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

        expect(product.reload).to be
        expect(product.primary_image).to be
        expect(product.primary_image.url).to eq 'zzzzzz'
      end

      it 'accept url as thumb image' do
        params[:store_product][:thumb_image_url] = 'zzzzzz'

        put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

        expect(product.reload).to be
        expect(product.thumb_image).to be
        expect(product.thumb_image.url).to eq 'zzzzzz'
      end
    end

    context 'with attributes' do
      let(:group) { create :attribute_group, name: 'MOODS' }
      let(:group_attribute) { create :attribute_def, name: 'Relaxed', attribute_group: group }
      let(:attribute) { create :attribute_def, name: 'THC' }
      let(:variant) { create :product_variant, name: 'product variant', tag_list: 'tag 1, tag 2' }
      let(:product) { create :store_product, name: 'Store Product', product_variant: variant }

      let(:params) do
        {
          store_product: {
            attribute_values_attributes: [
              { id: product.attribute_values[0].id, value: '10' },
              { id: product.attribute_values[1].id, value: '20' }
            ]
          }
        }
      end

      before do
        product.attribute_values << build(:attribute_value, attribute_def: group_attribute, value: '1', target: product)
        product.attribute_values << build(:attribute_value, attribute_def: attribute, value: '2', target: product)
      end

      it 'update attributes values' do
        put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

        expect(product.reload).to be
        expect(product.attribute_values.count).to eq 2
        expect(product.attribute_values[0].value).to eq '10'
        expect(product.attribute_values[1].value).to eq '20'
      end

      context 'destroy and attribute' do
        let(:params) do
          {
            store_product: {
              attribute_values_attributes: [
                { id: product.attribute_values[0].id, value: '10' },
                { id: product.attribute_values[1].id, value: '20', _destroy: true }
              ]
            }
          }
        end

        it 'update attributes' do
          put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

          expect(product.reload).to be
          expect(product.attribute_values.count).to eq 1
          expect(product.attribute_values[0].value).to eq '10'
        end
      end

      context 'create a new attribute' do
        let(:params) do
          {
            store_product: {
              attribute_values_attributes: [{ attribute_def_id: group_attribute.id, value: '30' }]
            }
          }
        end

        it 'update attributes' do
          put store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

          expect(product.reload).to be
          expect(product.attribute_values.count).to eq 3
          expect(product.attribute_values.map(&:value)).to match_array %w[1 2 30]
        end
      end
    end
  end

  def product_search_json(product)
    p_json = product.as_json(only: %i[id sku])
    p_json['name'] = product.name_for_catalog
    p_json['stock'] = product.stock
    p_json['store_category'] = category_search_json(product.store_category)
    p_json['product_variant'] = product_variant_search_json(product.product_variant)
    p_json['brand'] = product.brand.as_json(only: %i[id name])
    p_json['status'] = product.status
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

  context '#show' do
    let(:params) { { id: product.id } }
    let(:product) { create :store_product, name: 'Product' }

    it 'return product' do
      get store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

      expect(json).to have_key('store_product')
      expect(json['store_product']).to eq(store_product_json(product.reload))
    end
  end

  context '#search' do
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
    let(:expected_products) { products.map { |p| product_search_json(p) } }

    before do
      create :store_product, name: 'new name', product_variant: variants[1], store_category: category
      create :store_product, name: 'BProduct 1', product_variant: variants[0], store_category: category
      create :product_variant, name: 'BProduct 1', product: master_product2
      create :product_variant, name: 'CProduct 4'

      get search_store_store_products_path(store), params: { name: 'aproduct' }, headers: auth_headers(user)
    end

    context 'filter by name' do
      before do
        get search_store_store_products_path(store), params: { name: 'aproduct' }, headers: auth_headers(user)
      end

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json).not_to have_key('meta')
        expect(json['store_products'].count).to eq 4
        expect(json['store_products']).to eq expected_products
      end
    end

    context 'filter by product_variant' do
      let(:expected_products) do
        StoreProduct
          .joins(product_variant: :product)
          .where(product_variant_id: variants[1])
          .order(Arel.sql('COALESCE(store_products.name, product_variants.name, products.name)'))
          .map { |p| product_search_json(p) }
      end

      before { get search_store_store_products_path(store), params: { product_variant_id: variants[1].id }, headers: auth_headers(user) }

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json).not_to have_key('meta')
        expect(json['store_products'].count).to eq 2
        expect(json['store_products']).to eq expected_products
      end
    end

    context 'filter by tag' do
      let(:expected_products) do
        StoreProduct.name_like('aproduct').deep_tagged_with('tag 1')
                    .order(Arel.sql('COALESCE(store_products.name, product_variants.name, products.name)'))
                    .map { |p| product_search_json(p) }
      end

      before { get search_store_store_products_path(store), params: { name: 'aproduct', tag: 'tag 1' }, headers: auth_headers(user) }

      it 'respond with filtered products' do
        expect(json).to have_key('store_products')
        expect(json).not_to have_key('meta')
        expect(json['store_products'].count).to eq 3
        expect(json['store_products']).to eq expected_products
      end
    end
  end

  context '#destroy' do
    let(:params) { { id: product.id, store_product: { name: 'new name', tag_list: 'tag 1, tag 3' } } }
    let!(:product) { create :store_product, name: 'Store Product', sku: '1234' }

    it 'destroy product' do
      expect do
        delete store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)
      end.to change { StoreProduct.count }.by -1
    end

    it 'return empty' do
      delete store_store_product_path(product.store_id, product), params: params, headers: auth_headers(user)

      expect(json).to eq ({})
    end
  end
end
