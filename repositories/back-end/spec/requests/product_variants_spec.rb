require 'rails_helper'

describe 'ProductVariant API' do
  let(:user) { create :user }

  def variant_json(variant, full: false)
    v_json = variant.as_json(
      only: %i[id name sku description override_tags],
      methods: [:tag_list],
      include: { video: { only: %i[id url] } }
    )

    v_json['is_wildcard'] = variant.id == ENV['WILDCARD_VARIANT_ID'].to_i
    v_json['video'] = nil unless v_json['video']
    v_json['brand'] = nil
    v_json['brand'] = variant.brand.as_json(only: %i[id name description]) if variant.brand
    v_json['product'] = nil
    v_json['product'] = variant.product.as_json(only: %i[id name]) if variant.product

    v_json['category'] = variant.category.as_json(only: %i[id name])
    v_json['tag_list'].sort!
    v_json['attribute_values'] = []
    v_json['reviews'] = []
    v_json['images'] = []

    if full
      v_json['attribute_values'] = variant.attribute_values.map do |attr_val|
        val_json = attr_val.as_json(
          only: %i[id value], include: { attribute_def: {
            only: %i[id name restricted values], include: { attribute_group: {
              only: %i[id name group_type order]
            } }
          } }
        )
        val_json
      end
      v_json['images'] = variant.images.map do |image|
        image.as_json(:id, :url)
      end
      v_json['reviews'] = variant.reviews.map do |review|
        review.as_json(only: %i[id user rate text reviewable_type reviewable_id])
      end
    end

    v_json
  end

  def product_search_json(product)
    p_json = product.as_json(only: %i[id name product_id])
    p_json['name'] = product.product.name if p_json['name'].blank?
    p_json['brand'] = product.brand.as_json(only: %i[id name]) if product.brand
    p_json
  end

  context '#index' do
    let(:variants) { ProductVariant.all.order(id: :desc) }
    let(:expected_variants) { variants.map { |c| variant_json(c) } }

    before do
      create_list :product_variant, 3
      get product_variants_path, headers: auth_headers(user)
    end

    it 'respond with product_variants' do
      expect(json).to have_key('product_variants')
      expect(json['product_variants'].count).to eq 3
      expect(json['product_variants']).to eq expected_variants
    end
  end

  context '#index#sort' do
    let(:variants) { ProductVariant.all.order(name: :asc) }
    let(:expected_variants) { variants.map { |c| variant_json(c) } }

    before do
      create :product_variant, name: 'Product variant 3', sku: 'sku 3'
      create :product_variant, name: 'Product variant 1', sku: 'sku 1'
      create :product_variant, name: 'Product variant 2', sku: 'sku 2'
    end

    it 'respond with sorted product_variants by name' do
      get product_variants_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)

      expect(json).to have_key('product_variants')
      expect(json['product_variants'].count).to eq 3
      expect(json['product_variants']).to eq expected_variants
    end

    it 'respond with sorted product_variants by sku' do
      get product_variants_path, params: { sort_by: 'sku', sort_direction: 'asc' }, headers: auth_headers(user)

      expect(json).to have_key('product_variants')
      expect(json['product_variants'].count).to eq 3
      expect(json['product_variants']).to eq expected_variants.sort_by { |variant| variant['sku'] }
    end

    it 'respond with sorted product_variants by brand' do
      get product_variants_path, params: { sort_by: 'brand.name', sort_direction: 'asc' }, headers: auth_headers(user)

      expect(json).to have_key('product_variants')
      expect(json['product_variants'].count).to eq 3
      expect(json['product_variants']).to eq expected_variants.sort_by { |variant| variant['brand']['name'] }
    end
  end

  context '#index#filter by product' do
    let(:variants) { ProductVariant.all.where(product_id: variant_1.product_id).order(id: :desc) }
    let(:expected_variants) { variants.map { |c| variant_json(c) } }
    let(:product) { variant_1.product }
    let!(:variant_1) { create :product_variant, name: 'Product 1 variant 1' }
    let!(:variant_2) { create :product_variant, name: 'Product 1 variant 2', product: product }

    before do
      create :product_variant, name: 'Product 2 variant 3'
      get product_variants_path, params: { product_id: product.id }, headers: auth_headers(user)
    end

    it 'respond with filtered product_variants' do
      expect(json).to have_key('product_variants')
      expect(json['product_variants'].count).to eq 2
      expect(json['product_variants']).to eq expected_variants
    end
  end

  context '#index#filter by category' do
    let(:variants) { ProductVariant.joins(:product).merge(Product.where(category_id: variant_1.category)).order(id: :desc) }
    let(:expected_variants) { variants.map { |c| variant_json(c) } }
    let(:product) { variant_1.product }
    let!(:variant_1) { create :product_variant, name: 'Product 1 variant 1' }
    let!(:variant_2) { create :product_variant, name: 'Product 1 variant 2', product: product }

    before do
      create :product_variant, name: 'Product 2 variant 3'
      get product_variants_path, params: { product_category_id: product.category.id }, headers: auth_headers(user)
    end

    it 'respond with filtered product_variants' do
      expect(json).to have_key('product_variants')
      expect(json['product_variants'].count).to eq 2
      expect(json['product_variants']).to eq expected_variants
    end
  end

  context '#index#filter by brand' do
    let(:variants) { ProductVariant.where(brand_id: variant_1.brand_id).order(id: :desc) }
    let(:expected_variants) { variants.map { |c| variant_json(c) } }
    let(:product) { variant_1.product }
    let!(:variant_1) { create :product_variant, name: 'Product 1 variant 1' }
    let!(:variant_2) { create :product_variant, name: 'Product 1 variant 2', product: product }

    before do
      create :product_variant, name: 'Product 2 variant 3'
      get product_variants_path, params: { brand_id: variant_1.brand.id }, headers: auth_headers(user)
    end

    it 'respond with filtered product_variants' do
      expect(json).to have_key('product_variants')
      expect(json['product_variants'].count).to eq 1
      expect(json['product_variants']).to eq expected_variants
    end
  end

  context 'index#full_text_search' do
    let(:expected_products) { [] }

    context 'when algolia is enabled' do
      before do
        variants = double
        allow(variants).to receive(:raw_answer).and_return('nbHits' => 0)
        allow(variants).to receive(:count).and_return 0
        allow(variants).to receive(:first).and_return(ProductVariant.all)

        expect(ProductVariant).to receive(:search).and_return(variants)
        get product_variants_path, params: { q: 'product' }, headers: auth_headers(user)
      end

      it 'respond with filtered product_variants' do
        expect(json).to have_key('product_variants')
        expect(json['product_variants'].count).to eq 0
        expect(json['product_variants']).to eq expected_products
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

      before { get product_variants_path, params: { q: 'product' }, headers: auth_headers(user) }

      it "don't use algolia" do
        expect(ProductVariant).not_to receive(:search)
      end

      it 'fallback to name like' do
        expect(ProductVariant).not_to receive(:name_like)
      end

      it 'respond with filtered product_variants' do
        expect(json).to have_key('product_variants')
        expect(json['product_variants'].count).to eq 0
        expect(json['product_variants']).to eq expected_products
      end
    end
  end

  context '#search' do
    let(:master_product) { create :product, name: 'AProduct 1' }
    let(:master_product2) { create :product, name: 'AProduct 2' }
    let!(:products) do
      [
        create(:product_variant, name: 'AProduct 2'),
        create(:product_variant, name: 'AProduct 3'),
        create(:product_variant, name: nil, product: master_product)
      ]
    end
    let(:expected_products) { products.map { |p| product_search_json(p) } }

    before do
      create :product_variant, name: 'BProduct 1', product: master_product2
      create :product_variant, name: 'CProduct 4'
      get search_product_variants_path, params: { name: 'aproduct', sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with filtered products' do
      expect(json).to have_key('product_variants')
      expect(json).not_to have_key('meta')
      expect(json['product_variants'].count).to eq 3
      expect(json['product_variants']).to eq expected_products
    end
  end

  it_behaves_like 'paginated resource', Brand

  context '#create' do
    let(:product) { create :product }
    let(:variant) { ProductVariant.last }
    let(:params) do
      {
        product_variant: {
          name: 'product variant 1', product_id: product.id, sku: 'XXX_1',
          description: 'description', tag_list: 'tag 2, tag 1', override_tags: true,
          video_attributes: { id: nil, url: 'http://www.youtube.com' }
        }
      }
    end
    let(:missing_prod_params) { { product_variant: { product_id: '', sku: 'XXX_1' } } }

    it 'create variant' do
      expect do
        post product_variants_path, params: params, headers: auth_headers(user)
      end.to change {
        ProductVariant.count
      }.by 1
    end

    it 'created variant values' do
      post product_variants_path, params: params, headers: auth_headers(user)

      expect(variant).to be
      expect(variant.name).to eq 'product variant 1'
      expect(variant.description).to eq 'description'
      expect(variant.sku).to eq 'XXX_1'
      expect(variant.video_url).to eq 'http://www.youtube.com'
      expect(variant.product_id).to eq product.id
      expect(variant.tags.count).to eq 2
      expect(variant.tag_list).to match_array ['tag 1', 'tag 2']
      expect(variant.override_tags).to be
    end

    it 'respond with variant' do
      post product_variants_path, params: params, headers: auth_headers(user)

      expect(json).to have_key('product_variant')
      json['product_variant']['tag_list'].sort!
      expect(json['product_variant']).to eq variant_json(variant)
    end

    it 'assign defautl image' do
      image = create :image, imageable: product
      post product_variants_path, params: params, headers: auth_headers(user)

      expect(variant.reload.images.count).to eq 1
      expect(variant.images.first.url).to eq image.url
    end

    it 'return errors' do
      post product_variants_path, params: missing_prod_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('product')
      expect(json['errors']).to eq('product' => ['must exist'])
    end

    context 'with attributes' do
      let(:group) { create :attribute_group, name: 'MOODS' }
      let(:group_attribute) { create :attribute_def, name: 'Relaxed', attribute_group: group }
      let(:attribute) { create :attribute_def, name: 'THC' }
      let(:params) do
        {
          product_variant: {
            name: 'Product 1', product_id: product.id, sku: 'XXX_1',
            attribute_values_attributes: [
              { attribute_def_id: group_attribute.id, value: '0.65' },
              { attribute_def_id: attribute.id, value: '0.90' }
            ]
          }
        }
      end

      it 'create attributes values' do
        post product_variants_path, params: params, headers: auth_headers(user)

        expect(variant).to be
        expect(variant.attribute_values.count).to eq 2
        expect(variant.attribute_values.find_by(attribute_def_id: group_attribute.id)).to be
        expect(variant.attribute_values.find_by(attribute_def_id: attribute.id)).to be
      end
    end

    context 'with images' do
      let(:image) { create :image, imageable: product }
      let(:params) do
        {
          product_variant: {
            name: 'Product 1', product_id: product.id, sku: 'XXX_1',
            image_ids: [image.id]
          }
        }
      end

      it 'create images' do
        post product_variants_path, params: params, headers: auth_headers(user)

        expect(variant).to be
        expect(variant.images.count).to eq 1
        expect(variant.images.first.url).to eq image.url
      end
    end

    context 'with reviews' do
      let(:params) do
        {
          product_variant: {
            name: 'Product 1', product_id: product.id, sku: 'XXX_1',
            reviews_attributes: [
              { user: 'User 1', rate: '1', text: 'review text 1' },
              { user: 'User 2', rate: '1', text: 'review text 1' }
            ]
          }
        }
      end

      it 'create reviews' do
        post product_variants_path, params: params, headers: auth_headers(user)

        expect(variant).to be
        expect(variant.reviews.count).to eq 2
        expect(variant.reviews.find_by(user: 'User 1')).to be
        expect(variant.reviews.find_by(user: 'User 2')).to be
      end
    end
  end

  context '#update' do
    let(:params) { { id: variant.id, product_variant: { name: 'new name', tag_list: 'tag 1, tag 3' } } }
    let(:variant) { create :product_variant, name: 'product variant', tag_list: 'tag 1, tag 2' }
    let(:missing_name_params) { { product_variant: { product_id: '' } } }

    it 'update product' do
      put product_variant_path(variant), params: params, headers: auth_headers(user)

      expect(variant.reload.name).to eq 'new name'
      expect(variant.tags.count).to eq 2
      expect(variant.tag_list).to match_array ['tag 1', 'tag 3']
    end

    it 'return updated product' do
      put product_variant_path(variant), params: params, headers: auth_headers(user)

      expect(json).to have_key('product_variant')
      json['product_variant']['tag_list'].sort!
      expect(json['product_variant']).to eq variant_json(variant.reload)
    end

    it 'return errors' do
      put product_variant_path(variant), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('product')
      expect(json['errors']).to eq('product' => ['must exist'])
    end

    context 'with attributes' do
      let(:group) { create :attribute_group, name: 'MOODS' }
      let(:group_attribute) { create :attribute_def, name: 'Relaxed', attribute_group: group }
      let(:attribute) { create :attribute_def, name: 'THC' }
      let(:params) do
        {
          product_variant: {
            attribute_values_attributes: [
              { id: variant.attribute_values[0].id, value: '10' },
              { id: variant.attribute_values[1].id, value: '20' }
            ]
          }
        }
      end

      before do
        variant.attribute_values << build(:attribute_value, attribute_def: group_attribute, value: '1')
        variant.attribute_values << build(:attribute_value, attribute_def: attribute, value: '2')
      end

      it 'update attributes values' do
        put product_variant_path(variant), params: params, headers: auth_headers(user)

        expect(variant.reload).to be
        expect(variant.attribute_values.count).to eq 2
        expect(variant.attribute_values[0].value).to eq '10'
        expect(variant.attribute_values[1].value).to eq '20'
      end

      context 'destroy and attribute' do
        let(:params) do
          {
            product_variant: {
              attribute_values_attributes: [
                { id: variant.attribute_values[0].id, value: '10' },
                { id: variant.attribute_values[1].id, value: '20', _destroy: true }
              ]
            }
          }
        end

        it 'update attributes' do
          put product_variant_path(variant), params: params, headers: auth_headers(user)

          expect(variant.reload).to be
          expect(variant.attribute_values.count).to eq 1
          expect(variant.attribute_values[0].value).to eq '10'
        end
      end

      context 'create a new attribute' do
        let(:params) do
          {
            product_variant: {
              attribute_values_attributes: [{ attribute_def_id: group_attribute.id, value: '30' }]
            }
          }
        end

        it 'update attributes' do
          put product_variant_path(variant), params: params, headers: auth_headers(user)

          expect(variant.reload).to be
          expect(variant.attribute_values.count).to eq 3
          expect(variant.attribute_values.map(&:value)).to match_array %w[30 2 1]
        end
      end
    end

    context 'with images' do
      let(:product) { variant.product }
      let(:image) { create :image, imageable: product }
      let(:params) do
        {
          product_variant: {
            name: 'Product 1', product_id: product.id,
            image_ids: [image.id]
          }
        }
      end

      before do
        image.touch
        product.images << create(:image, imageable: product)
        product.images.each { |i| variant.images << i }
      end

      it 'create images' do
        expect(variant.images.count).to eq 2

        put product_variant_path(variant), params: params, headers: auth_headers(user)

        expect(variant.reload.images.count).to eq 1
        expect(variant.reload.image_ids).to eq [image.id]
      end
    end

    context 'with reviews' do
      let(:params) do
        {
          product_variant: {
            reviews_attributes: [
              { id: variant.reviews[0].id, user: 'User 1', rate: '10', text: 'review text 1' },
              { id: variant.reviews[1].id, user: 'User 2', rate: '8', text: 'review text 2' }
            ]
          }
        }
      end

      before do
        variant.reviews << build(:review, user: 'user')
        variant.reviews << build(:review, user: 'user')
      end

      it 'update reviews' do
        put product_variant_path(variant), params: params, headers: auth_headers(user)

        expect(variant.reload).to be
        expect(variant.reviews.count).to eq 2
        expect(variant.reviews[0].user).to eq 'User 1'
        expect(variant.reviews[1].user).to eq 'User 2'
      end

      context 'destroy a review' do
        let(:params) do
          {
            product_variant: {
              reviews_attributes: [
                { id: variant.reviews[1].id, _destroy: true }
              ]
            }
          }
        end

        it 'destryo the review' do
          put product_variant_path(variant), params: params, headers: auth_headers(user)

          expect(variant.reload).to be
          expect(variant.reviews.count).to eq 1
        end
      end

      context 'create a new review' do
        let(:params) do
          {
            product_variant: {
              reviews_attributes: [{ user: 'User 66', text: '1111' }]
            }
          }
        end

        it 'update images' do
          put product_variant_path(variant), params: params, headers: auth_headers(user)

          expect(variant.reload).to be
          expect(variant.reviews.count).to eq 3
          expect(variant.reviews.map(&:user)).to include 'User 66'
        end
      end
    end
  end

  context '#show' do
    let(:params) { { id: variant.id } }
    let(:variant) { create :product_variant, name: 'Brand' }

    before do
      variant.attribute_values << build(:attribute_value)
      variant.attribute_values << build(:attribute_value)
    end

    it 'return product' do
      get product_variant_path(variant), params: params, headers: auth_headers(user)

      expect(json).to have_key('product_variant')
      expect(json['product_variant']).to eq(variant_json(variant, full: true))
    end
  end

  context '#tags' do
    let(:params) { { id: variant.id } }
    let(:variant) { create :product_variant, tag_list: 'tag 1, tag 2, tag 4' }

    it 'return product' do
      get tags_product_variant_path(variant), params: params, headers: auth_headers(user)

      expect(json).to have_key('tags')
      expect(json['tags']).to match_array ['tag 1', 'tag 2', 'tag 4']
    end
  end
end
