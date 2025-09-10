require 'rails_helper'

describe 'Products API' do
  let(:user) { create :user }

  def product_json(product, full: false)
    includes = {
      category: { only: %i[id name] },
      video: { only: %i[id url] }
    }
    p_json = product.as_json(only: %i[id name description], include: includes, methods: [:tag_list])
    p_json['tag_list'].sort!
    p_json['attribute_values'] = []
    p_json['images'] = []
    p_json['reviews'] = []
    p_json['video'] = nil unless p_json['video']

    if full
      p_json['attribute_values'] = product.attribute_values.map do |attr_val|
        val_json = attr_val.as_json(
          only: %i[id value], include: { attribute_def: {
            only: %i[id name restricted values], include: { attribute_group: {
              only: %i[id name group_type order]
            } }
          } }
        )
        val_json
      end

      p_json['images'] = product.images.map do |image|
        image.as_json(only: %i[id url])
      end

      p_json['reviews'] = product.reviews.map do |review|
        review.as_json(only: %i[id user rate text reviewable_type reviewable_id])
      end
    end

    p_json
  end

  def product_search_json(product)
    includes = {
      category: { only: %i[id name] }
    }
    product.as_json(only: %i[id name], include: includes)
  end

  context '#index' do
    let(:products) { Product.all.order(id: :desc) }
    let(:expected_products) { products.map { |p| product_json(p) } }

    before do
      create_list :product, 3
      get products_path, headers: auth_headers(user)
    end

    it 'respond with products' do
      expect(json).to have_key('products')
      expect(json['products'].count).to eq 3
      expect(json['products']).to eq expected_products
    end
  end

  context '#index#sort' do
    let(:products) { Product.all.order(name: :asc) }
    let(:expected_products) { products.map { |p| product_json(p) } }

    before do
      create :product, name: 'Product 3'
      create :product, name: 'Product 1'
      create :product, name: 'Product 2'
      get products_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted products' do
      expect(json).to have_key('products')
      expect(json['products'].count).to eq 3
      expect(json['products']).to eq expected_products
    end
  end

  context '#index#filtered by category' do
    let(:products) { Product.all.where(category_id: category.id).order(name: :asc) }
    let(:expected_products) { products.map { |p| product_json(p) } }
    let(:category) { create :category }

    before do
      create :product, name: 'Product 3', category: category
      create :product, name: 'Product 1', category: category
      create :product, name: 'Product 2'
      get products_path, params: { category_id: category.id, sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted products' do
      expect(json).to have_key('products')
      expect(json['products'].count).to eq 2
      expect(json['products']).to eq expected_products
    end
  end

  context '#index#filtered by name' do
    let(:products) { Product.all.where("products.name ILIKE '%product 1%'").order(name: :asc) }
    let(:expected_products) { products.map { |p| product_json(p) } }

    before do
      create :product, name: 'Product 3'
      create :product, name: 'Product 11'
      create :product, name: 'Product 1'
      get products_path, params: { name: 'product 1', sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted products' do
      expect(json).to have_key('products')
      expect(json['products'].count).to eq 2
      expect(json['products']).to match_array expected_products
    end
  end

  context '#index#filtered by brand' do
    let(:products) { create_list :product, 3 }
    let(:expected_products) { products[0..1].map { |p| product_json(p) } }
    let(:brand) { create :brand, name: 'brand 2' }

    before do
      create :product_variant, product: products[0], brand: create(:brand)
      create :product_variant, product: products[0], brand: brand
      create :product_variant, product: products[0], brand: brand
      create :product_variant, product: products[1], brand: brand
      create :product_variant, product: products[2], brand: create(:brand)
      create :product_variant, product: products[2], brand: create(:brand)
    end

    it 'respond with filtered products' do
      get products_path, params: { brand_id: brand.id }, headers: auth_headers(user)

      expect(json).to have_key('products')
      expect(json['products'].count).to eq 2
      expect(json['products']).to match_array expected_products
    end
  end

  context 'index#full_text_search' do
    let(:expected_products) { [] }

    context 'when algolia is enabled' do
      before do
        prods = double
        allow(prods).to receive(:raw_answer).and_return('nbHits' => 0)
        allow(prods).to receive(:count).and_return 0
        allow(prods).to receive(:first).and_return(Product.all)

        expect(Product).to receive(:search).and_return(prods)
        get products_path, params: { q: 'product' }, headers: auth_headers(user)
      end

      it 'respond with filtered products' do
        expect(json).to have_key('products')
        expect(json['products'].count).to eq 0
        expect(json['products']).to eq expected_products
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

      before { get products_path, params: { q: 'product' }, headers: auth_headers(user) }

      it "don't use algolia" do
        expect(Product).not_to receive(:search)
      end

      it 'fallback to name like' do
        expect(Product).not_to receive(:name_like)
      end

      it 'respond with filtered products' do
        expect(json).to have_key('products')
        expect(json['products'].count).to eq 0
        expect(json['products']).to eq expected_products
      end
    end
  end

  context '#search' do
    let!(:products) do
      [
        create(:product, name: 'AProduct 2'), create(:product, name: 'AProduct 3')
      ]
    end
    let(:expected_products) { products.map { |p| product_search_json(p) } }

    before do
      create :product, name: 'BProduct 1'
      create :product, name: 'CProduct 4'
      get search_products_path, params: { name: 'aproduct', sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with filtered products' do
      expect(json).to have_key('products')
      expect(json).not_to have_key('meta')
      expect(json['products'].count).to eq 2
      expect(json['products']).to eq expected_products
    end
  end

  it_behaves_like 'paginated resource', Product

  context '#create' do
    let(:category) { create :category }
    let(:product) { Product.last }
    let(:params) do
      {
        product: {
          name: 'Product 1', category_id: category.id,
          description: 'description', video_attributes: { id: nil, url: 'http://www.youtube.com' },
          tag_list: 'tag 2, tag 1'
        }
      }
    end
    let(:missing_name_params) { { product: { category_id: category.id } } }

    it 'create product' do
      expect do
        post products_path, params: params, headers: auth_headers(user)
      end.to change {
        Product.count
      }.by 1
    end

    it 'created product values' do
      post products_path, params: params, headers: auth_headers(user)

      expect(product).to be
      expect(product.name).to eq 'Product 1'
      expect(product.category_id).to eq category.id
      expect(product.description).to eq 'description'
      expect(product.video.url).to eq 'http://www.youtube.com'
      expect(product.tags.count).to eq 2
      expect(product.tag_list).to match_array ['tag 1', 'tag 2']
    end

    it 'respond with product' do
      post products_path, params: params, headers: auth_headers(user)

      expect(json).to have_key('product')
      json['product']['tag_list'].sort!
      expect(json['product']).to eq product_json(product)
    end

    it 'return errors' do
      post products_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end

    context 'with attributes' do
      let(:group) { create :attribute_group, name: 'MOODS' }
      let(:group_attribute) { create :attribute_def, name: 'Relaxed', attribute_group: group }
      let(:attribute) { create :attribute_def, name: 'THC' }
      let(:params) do
        {
          product: {
            name: 'Product 1', category_id: category.id, description: 'description',
            attribute_values_attributes: [
              { attribute_def_id: group_attribute.id, value: '0.65' },
              { attribute_def_id: attribute.id, value: '0.90' }
            ]
          }
        }
      end

      it 'create attributes values' do
        post products_path, params: params, headers: auth_headers(user)

        expect(product).to be
        expect(product.attribute_values.count).to eq 2
        expect(product.attribute_values.find_by(attribute_def_id: group_attribute.id)).to be
        expect(product.attribute_values.find_by(attribute_def_id: attribute.id)).to be
      end
    end

    context 'with images' do
      let(:params) do
        {
          product: {
            name: 'Product 1', category_id: category.id, description: 'description',
            images_attributes: [
              { url: 'image_url 1' },
              { url: 'image_url 2' }
            ]
          }
        }
      end

      it 'create images' do
        post products_path, params: params, headers: auth_headers(user)

        expect(product).to be
        expect(product.images.count).to eq 2
        expect(product.images.find_by(url: 'image_url 1')).to be
        expect(product.images.find_by(url: 'image_url 2')).to be
      end
    end

    context 'with reviews' do
      let(:params) do
        {
          product: {
            name: 'Product 1', category_id: category.id, description: 'description',
            reviews_attributes: [
              { user: 'User 1', rate: '1', text: 'review text 1' },
              { user: 'User 2', rate: '1', text: 'review text 1' }
            ]
          }
        }
      end

      it 'create reviews' do
        post products_path, params: params, headers: auth_headers(user)

        expect(product).to be
        expect(product.reviews.count).to eq 2
        expect(product.reviews.find_by(user: 'User 1')).to be
        expect(product.reviews.find_by(user: 'User 2')).to be
      end
    end
  end

  context '#update' do
    let(:params) { { id: product.id, product: { name: 'new name', tag_list: 'tag 1, tag 3' } } }
    let(:product) { create :product, name: 'Product', tag_list: 'tag 1, tag 2' }
    let(:missing_name_params) { { product: { name: '' } } }

    it 'update product' do
      put product_path(product), params: params, headers: auth_headers(user)

      expect(product.reload.name).to eq 'new name'
      expect(product.tags.count).to eq 2
      expect(product.tag_list).to match_array ['tag 1', 'tag 3']
    end

    it 'return updated product' do
      put product_path(product), params: params, headers: auth_headers(user)

      expect(json).to have_key('product')
      json['product']['tag_list'].sort!
      expect(json['product']).to eq product_json(product.reload)
    end

    it 'return errors' do
      put product_path(product), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end

    context 'with attributes' do
      let(:group) { create :attribute_group, name: 'MOODS' }
      let(:group_attribute) { create :attribute_def, name: 'Relaxed', attribute_group: group }
      let(:attribute) { create :attribute_def, name: 'THC' }
      let(:params) do
        {
          product: {
            attribute_values_attributes: [
              { id: product.attribute_values[0].id, value: '10' },
              { id: product.attribute_values[1].id, value: '20' }
            ]
          }
        }
      end

      before do
        product.attribute_values << build(:attribute_value, attribute_def: group_attribute, value: '1')
        product.attribute_values << build(:attribute_value, attribute_def: attribute, value: '2')
      end

      it 'update attributes values' do
        put product_path(product), params: params, headers: auth_headers(user)

        expect(product.reload).to be
        expect(product.attribute_values.count).to eq 2
        expect(product.attribute_values[0].value).to eq '10'
        expect(product.attribute_values[1].value).to eq '20'
      end

      context 'destroy and attribute' do
        let(:params) do
          {
            product: {
              attribute_values_attributes: [
                { id: product.attribute_values[0].id, value: '10' },
                { id: product.attribute_values[1].id, value: '20', _destroy: true }
              ]
            }
          }
        end

        it 'update attributes' do
          put product_path(product), params: params, headers: auth_headers(user)

          expect(product.reload).to be
          expect(product.attribute_values.count).to eq 1
          expect(product.attribute_values[0].value).to eq '10'
        end
      end

      context 'create a new attribute' do
        let(:params) do
          {
            product: {
              attribute_values_attributes: [{ attribute_def_id: group_attribute.id, value: '30' }]
            }
          }
        end

        it 'update attributes' do
          put product_path(product), params: params, headers: auth_headers(user)

          expect(product.reload).to be
          expect(product.attribute_values.count).to eq 3
          expect(product.attribute_values.map(&:value)).to match_array %w[1 2 30]
        end
      end
    end

    context 'with images' do
      let(:params) do
        {
          product: {
            images_attributes: [
              { id: product.images[0].id, url: 'new url 1' },
              { id: product.images[1].id, url: 'new url 2' }
            ]
          }
        }
      end

      before do
        product.images << build(:image, imageable: product)
        product.images << build(:image, imageable: product)
      end

      it 'update images values' do
        put product_path(product), params: params, headers: auth_headers(user)

        expect(product.reload).to be
        expect(product.images.count).to eq 2
        expect(product.images[0].url).to eq 'new url 1'
        expect(product.images[1].url).to eq 'new url 2'
      end

      context 'destroy and image' do
        let(:params) do
          {
            product: {
              images_attributes: [
                { id: product.images[1].id, _destroy: true }
              ]
            }
          }
        end

        it 'update attributes' do
          put product_path(product), params: params, headers: auth_headers(user)

          expect(product.reload).to be
          expect(product.images.count).to eq 1
        end
      end

      context 'create a new image' do
        let(:params) do
          {
            product: {
              images_attributes: [{ url: 'new url' }]
            }
          }
        end

        it 'update images' do
          put product_path(product), params: params, headers: auth_headers(user)

          expect(product.reload).to be
          expect(product.images.count).to eq 3
          expect(product.images.map(&:url)).to include 'new url'
        end
      end
    end

    context 'with reviews' do
      let(:params) do
        {
          product: {
            reviews_attributes: [
              { id: product.reviews[0].id, user: 'User 1', rate: '10', text: 'review text 1' },
              { id: product.reviews[1].id, user: 'User 2', rate: '8', text: 'review text 2' }
            ]
          }
        }
      end

      before do
        product.reviews << build(:review, reviewable: product)
        product.reviews << build(:review, reviewable: product)
      end

      it 'update reviews' do
        put product_path(product), params: params, headers: auth_headers(user)

        expect(product.reload).to be
        expect(product.reviews.count).to eq 2
        expect(product.reviews[0].user).to eq 'User 1'
        expect(product.reviews[1].user).to eq 'User 2'
      end

      context 'destroy a review' do
        let(:params) do
          {
            product: {
              reviews_attributes: [
                { id: product.reviews[1].id, _destroy: true }
              ]
            }
          }
        end

        it 'destryo the review' do
          put product_path(product), params: params, headers: auth_headers(user)

          expect(product.reload).to be
          expect(product.reviews.count).to eq 1
        end
      end

      context 'create a new review' do
        let(:params) do
          {
            product: {
              reviews_attributes: [{ user: 'User 66', text: '1111' }]
            }
          }
        end

        it 'update images' do
          put product_path(product), params: params, headers: auth_headers(user)

          expect(product.reload).to be
          expect(product.reviews.count).to eq 3
          expect(product.reviews.map(&:user)).to include 'User 66'
        end
      end
    end
  end

  context '#show' do
    let(:params) { { id: product.id } }
    let(:product) { create :product, name: 'Product' }

    before do
      product.attribute_values << build(:attribute_value)
      product.attribute_values << build(:attribute_value)
      product.images << build(:image)
    end

    it 'return product' do
      get product_path(product), params: params, headers: auth_headers(user)

      expect(json).to have_key('product')
      expect(json['product']).to eq(product_json(product.reload, full: true))
    end
  end

  context '#tags' do
    let(:params) { { id: product.id } }
    let(:product) { create :product, tag_list: 'tag 1, tag 2, tag 4' }

    it 'return product' do
      get tags_product_path(product), params: params, headers: auth_headers(user)

      expect(json).to have_key('tags')
      expect(json['tags']).to match_array ['tag 1', 'tag 2', 'tag 4']
    end
  end
end
