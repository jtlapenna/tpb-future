require 'rails_helper'

describe 'API V1 Products' do
  include Api::V1::SerializationHelper::Products

  let(:kiosk) { create :kiosk, store: store }
  let(:store) { create :store, categories_count: 2 }

  describe '#index' do
    let(:product_variants) { create_list :product_variant, 3 }
    let(:expected_products) do
      kiosk.kiosk_products.joins(:store_product)
           .merge(StoreProduct.published).map { |p| kiosk_product_json(p) }
    end
    let(:categories) { store.store_categories }

    before do
      image_for_variant_1 = create(:image, imageable: product_variants[1].product)
      product_variants[1].images << image_for_variant_1
      product_variants[1].brand.logo = create(:asset, source: product_variants[1].brand)
      product_variants[1].reload

      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, product_variant: product_variants[0], tag_list: 'tag1, tag2', store_category: categories[0])
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, product_variant: product_variants[1], tag_list: 'tag2', images: [image_for_variant_1], primary_image: image_for_variant_1, store_category: categories[0])
      new_store_product = create(:store_product, product_variant: product_variants[2], store: store, store_category: categories[1])
      new_store_product.own_images << create(:image, imageable: new_store_product)
      create :kiosk_product, kiosk: kiosk, store_product: new_store_product

      create_list(:product_value, 2, valuable: new_store_product)
      # unpublished products, should not be returned
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, product_variant: product_variants[0], store_category: categories[0], status: :unpublished)
    end

    it 'respond with products' do
      get api_v1_products_path(kiosk), headers: auth_headers(store)

      expect(json).to have_key('products')
      expect(json['products'].count).to eq 3

      json['products'].each do |p|
        detected_prod = expected_products.detect { |prod| prod['id'] == p['id'] }

        expect(p).to match_product detected_prod
      end
      expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 3, 'total_pages' => 1)
    end

    context 'products with rfid' do
      let(:expected_products) do
        [
          kiosk_product_json(
            kiosk.kiosk_products.joins(:store_product).merge(StoreProduct.published)[0]
          )
        ]
      end
      let(:params) { { with_rfid: true } }

      before do
        prod = store.store_products.published[0].kiosk_products.first
        create :rfid_product, rfid_entity: prod, rfid: '123'
        create :rfid_product, rfid_entity: prod, rfid: '1234'
      end

      it 'return only products with rfid' do
        get api_v1_products_path(kiosk), params: params, headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 1
        expect(json['products'][0]['rfids']).to eq %w[123 1234]
        json['products'].each do |prod|
          detected_prod = expected_products.detect { |p| prod['id'] == p['id'] }

          expect(prod).to match_product detected_prod
        end
      end
    end

    context 'when product in catalog has no name' do
      let(:cps) { store.store_products.published }
      let(:cp_with_name) { cps[0] }
      let(:cp_with_name_on_product_variant) { cps[1] }
      let(:cp_with_name_on_product) { cps[2] }

      before do
        cp_with_name_on_product_variant.update_attribute :name, nil

        cp_with_name_on_product.update_attribute :name, nil
        cp_with_name_on_product.product_variant.update_attribute :name, nil

        get api_v1_products_path(kiosk.id), headers: auth_headers(store)
      end

      it 'respond product with' do
        expect(json['products'].detect { |cp| cp['id'] == cp_with_name.id }['name']).to eq cp_with_name.name
        expect(json['products'].detect { |cp| cp['id'] == cp_with_name_on_product_variant.id }['name']).to eq cp_with_name_on_product_variant.product_variant.name
        expect(json['products'].detect { |cp| cp['id'] == cp_with_name_on_product.id }['name']).to eq cp_with_name_on_product.product_variant.product.name
      end
    end

    context 'when product in catalog has no description' do
      let(:cps) { store.store_products.published }
      let(:cp_with_description) { cps[0] }
      let(:cp_with_description_on_product_variant) { cps[1] }
      let(:cp_with_description_on_product) { cps[2] }

      before do
        cp_with_description_on_product_variant.update_attribute :description, nil

        cp_with_description_on_product.update_attribute :description, nil
        cp_with_description_on_product.product_variant.update_attribute :description, nil

        get api_v1_products_path(kiosk.id), headers: auth_headers(store)
      end

      it 'respond product with' do
        expect(json['products'].detect { |cp| cp['id'] == cp_with_description.id }['description']).to eq cp_with_description.description
        expect(json['products'].detect { |cp| cp['id'] == cp_with_description_on_product_variant.id }['description']).to eq cp_with_description_on_product_variant.product_variant.description
        expect(json['products'].detect { |cp| cp['id'] == cp_with_description_on_product.id }['description']).to eq cp_with_description_on_product.product_variant.product.description
      end
    end

    context 'filtering by category' do
      let(:store_category) { store.store_categories[1] }

      before do
        get api_v1_products_path(kiosk), params: { category_id: store_category.id }, headers: auth_headers(store)
      end

      it 'respond only with the product on that category' do
        expect(json).to have_key('products')
        expect(json['products'].map { |cp| cp['id'] }).to match_array store_category.store_products.published.map(&:id)
      end
    end

    context 'filtering by brand' do
      let(:store_product_brand) { create :brand }
      let(:variant_brand) { create :brand }
      let(:store_products) { [product_variants[2].store_products.published.first, product_variants[0].store_products.published.first] }

      before do
        product_variants[0].update_attribute(:brand_id, variant_brand.id)
        product_variants[1].update_attribute(:brand_id, variant_brand.id)
        product_variants[0].store_products.published[0].update_attribute(:brand_id, store_product_brand.id)
        product_variants[2].update_attribute(:brand_id, store_product_brand.id)
      end

      it 'respond with catalog product brands' do
        get api_v1_products_path(kiosk), params: { brand_id: store_product_brand.id }, headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 2
        expect(json['products'].map { |cp| cp['id'] }).to match_array store_products.map(&:id)
      end

      context 'when brand is overriden on catalog product' do
        let(:store_products) { product_variants[1].store_products }

        it 'respond with product of catalog product brand' do
          get api_v1_products_path(kiosk), params: { brand_id: variant_brand.id }, headers: auth_headers(store)

          expect(json).to have_key('products')
          expect(json['products'].count).to eq 1
          expect(json['products'].map { |cp| cp['id'] }).to match_array store_products.map(&:id)
        end
      end
    end

    context 'variant of one catalog product with tag' do
      before do
        product_variant = StoreProduct.published.last.product_variant
        product_variant.tag_list.add('variant_tag')
        product_variant.save!

        product = StoreProduct.published.last.product_variant.product
        product.tag_list.add('product_tag')

        product.save!
      end

      it 'should be included in tags of his variant' do
        get api_v1_products_path(kiosk), headers: auth_headers(store)

        expect(json['products'].max_by { |p| p['id'] }['tag_list']).to include 'variant_tag'
      end

      it 'should be included in tags of his product' do
        get api_v1_products_path(kiosk), headers: auth_headers(store)

        expect(json['products'].max_by { |p| p['id'] }['tag_list']).to include 'product_tag'
      end
    end

    context 'filtering by featured tags' do
      let(:tag) { 'the_tag' }
      let(:store_product) { store.store_categories[0].store_products.published[0] }

      it 'respond only with the product with that tag' do
        source = store_product
        source.tag_list.add(tag)
        source.save!

        get api_v1_products_path(kiosk), params: { tagged_with: tag }, headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 1
        expect(json['products'][0]['id']).to eq store_product.id
      end

      it 'respond only with the product of variant with that tag' do
        source = store_product.product_variant
        source.tag_list.add(tag)
        source.save!

        get api_v1_products_path(kiosk), params: { tagged_with: tag }, headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 1
        expect(json['products'][0]['id']).to eq store_product.id
      end

      it 'respond only with the product of master product with that tag' do
        source = store_product.product_variant.product
        source.tag_list.add(tag)
        source.save!

        get api_v1_products_path(kiosk), params: { tagged_with: tag }, headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 1
        expect(json['products'][0]['id']).to eq store_product.id
      end
    end

    context 'ordering by name' do
      before do
        get api_v1_products_path(kiosk), params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(store)
      end

      it 'respond with the sorted list' do
        expect(json).to have_key('products')
        expect(json['products'].count).to eq 3
        expect(json['products']).to match_products expected_products.sort_by { |pr| pr['name'] }
      end
    end

    context 'ordering by brand' do
      before do
        get api_v1_products_path(kiosk), params: { sort_by: 'brand', sort_direction: 'asc' }, headers: auth_headers(store)
      end

      it 'respond with the sorted list' do
        expect(json).to have_key('products')
        expect(json['products'].count).to eq 3

        expect(json['products']).to match_products expected_products.sort_by { |pr| pr['brand']['name'] }
      end
    end

    context 'tags relevance and then order' do
      let(:expected_products) do
        ps = []

        # first the products taggeds in list sorted by name
        ps.concat store.store_products.tagged_with(%w[tag1 tag2], any: true).order('name')

        # last products out from tag list and sorted by name too:
        out_list_tags = StoreProduct.published.joins(%(LEFT JOIN taggings ON taggings.taggable_id=store_products.id AND taggings.taggable_type='StoreProduct')).where('taggings.id IS NULL')
        out_list_tags = (out_list_tags.to_a.concat StoreProduct.tagged_with('tag7').to_a).sort_by(&:name)
        ps.concat out_list_tags

        ps.map { |p| kiosk_product_json(p.kiosk_products.first) }
      end

      context 'with param tag1 first' do
        before do
          create :kiosk_product, kiosk: kiosk, store_product:
            create(:store_product, product_variant: product_variants[2], store: store, tag_list: 'tag1', store_category: create(:store_category, store: store))
          create :kiosk_product, kiosk: kiosk, store_product:
            create(:store_product, product_variant: product_variants[2], store: store, tag_list: 'tag7', store_category: create(:store_category, store: store))

          get api_v1_products_path(kiosk.id), params: { featured_tags: %w[tag1 tag2], sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(store)
        end

        it 'respond with the sorted list' do
          expect(json).to have_key('products')
          expect(json['products'].count).to eq 5
          expect(json['products']).to match_products expected_products
        end
      end
    end

    context 'accessing to another page' do
      before do
        get api_v1_products_path(kiosk.id), params: { sort_by: 'name', sort_direction: 'asc', per_page: 2, page: 2 }, headers: auth_headers(store)
      end

      it 'respond only with the product on that page' do
        expect(json).to have_key('products')
        expect(json['products'].count).to eq 1
        expect(json['products'][0]['id']).to eq expected_products.max_by { |pr| pr['name'] }['id']
      end
    end

    context 'searching' do
      let(:store_product) { store.store_categories[0].store_products[0] }
      let(:kiosk_product) { create :kiosk_product, kiosk: kiosk, store_product: store_product }

      before do
        prods = double
        allow(prods).to receive(:raw_answer).and_return('nbHits' => 1)
        allow(prods).to receive(:count).and_return 1
        allow(prods).to receive(:first).and_return([kiosk_product])
        expect(KioskProduct).to receive(:search).and_return(prods)

        get api_v1_products_path(kiosk.id), params: { q: 'product' }, headers: auth_headers(store)
      end

      it 'respond only with the product' do
        expect(json).to have_key('products')
        expect(json['products'].count).to eq 1
        expect(json['products'][0]['id']).to eq store_product.id
      end
    end
  end

  describe '#index_minimal' do
    let(:product_variants) { create_list :product_variant, 3 }
    let(:expected_products) do
      kiosk.kiosk_products.select { |p| p.store_product.published? }.map do |p|
        {
          id: p.store_product_id,
          sku: p.sku,
          stock: p.stock,
          created_at: p.created_at.iso8601(3),
          updated_at: [
            p,
            p.store_product,
            p.store_product.product_variant,
            p.store_product.product
          ].map(&:updated_at).max.iso8601(3)
        }.stringify_keys
      end
    end
    let(:categories) { store.store_categories }

    before do
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, product_variant: product_variants[0], store_category: categories[0])
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, product_variant: product_variants[1], store_category: categories[0])
      new_store_product = create(:store_product, product_variant: product_variants[2], store: store, store_category: categories[1])
      create :kiosk_product, kiosk: kiosk, store_product: new_store_product

      # unpublished products, should not be returned
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, product_variant: product_variants[0], store_category: categories[0], status: :unpublished)
    end

    it 'respond with products' do
      get minimal_api_v1_products_path(kiosk.id), headers: auth_headers(store)

      expect(json).to have_key('products')
      expect(json).not_to have_key('meta')
      expect(json['products'].count).to eq 3

      json['products'].each do |prod|
        expect(prod).to eq expected_products.detect { |p| p['id'] == prod['id'] }
      end
    end
  end

  describe '#show' do
    let(:product_variant) { create :product_variant }
    let!(:kiosk_product) { create :kiosk_product, store_product: store_product, kiosk: kiosk }
    let(:category) { store.store_categories[0] }
    let(:store_product) do
      build :store_product,
            product_variant: product_variant,
            tag_list: 'tag1, tag2',
            product_values: create_list(:product_value, 2),
            video: build(:asset),
            store_category: category
    end
    let(:expected_product) { kiosk_product_json(kiosk_product, include_attribute_values: true, include_layout: true) }

    before do
      create :rfid_product, rfid_entity: kiosk_product, rfid: '123'
      store.store_categories[0].store_products << store_product
      get "/api/v1/#{kiosk.id}/products/#{store_product.reload.id}", headers: auth_headers(store)
    end

    it 'respond with the product' do
      json_product_values = json['product'].delete('product_values')
      expected_product_values = expected_product.delete('product_values')
      expect(json['product']).to eq expected_product
      expect(json_product_values).to match_array expected_product_values
    end

    context 'with product attributes' do
      let!(:group1) { create :attribute_group, name: 'MOODS', order: 1 }
      let!(:group1_attribute1) { create :attribute_def, name: 'Relaxed', attribute_group: group1 }
      let!(:group1_attribute2) { create :attribute_def, name: 'Hungry', attribute_group: group1 }
      let!(:group2) { create :attribute_group, name: 'Effects', order: 12 }
      let!(:group2_attribute) { create :attribute_def, name: 'Anxious', attribute_group: group2 }
      let!(:ungrouped_attribute1) { create :attribute_def, name: 'THC', attribute_group: nil }
      let!(:ungrouped_attribute2) { create :attribute_def, name: 'CBD', attribute_group: nil }
      let(:expected_attribute_values) do
        { 'ungrouped' => [{ 'name' => 'CBD', 'value' => 'ABC' }, { 'name' => 'THC', 'value' => '2' }],
          'grouped' =>
           { 'MOODS' => [{ 'name' => 'Relaxed', 'value' => '1' }, { 'name' => 'Hungry', 'value' => '5' }],
             'Effects' => [{ 'name' => 'Anxious', 'value' => '0' }] } }
      end

      before do
        store_product.product.attribute_values << build(:attribute_value, attribute_def: group1_attribute1, value: '1')
        store_product.product.attribute_values << build(:attribute_value, attribute_def: group1_attribute2, value: '5')
        store_product.product.attribute_values << build(:attribute_value, attribute_def: group2_attribute, value: '0')
        store_product.product.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute1, value: '2')
        store_product.product.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute2, value: 'ABC')
        get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
      end

      it 'response include attributes' do
        expect(json['product']['attribute_values']).to match_attributes expected_attribute_values
      end

      context 'with some attributes override on the product variant' do
        let(:expected_attribute_values) do
          { 'ungrouped' => [{ 'name' => 'CBD', 'value' => 'DEF' }, { 'name' => 'THC', 'value' => '2' }],
            'grouped' =>
             { 'MOODS' => [{ 'name' => 'Relaxed', 'value' => '1' }, { 'name' => 'Hungry', 'value' => '10' }],
               'Effects' => [{ 'name' => 'Anxious', 'value' => '0' }] } }
        end

        before do
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: group1_attribute2, value: '10')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute2, value: 'DEF')
          get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
        end

        it 'response include attributes' do
          expect(json['product']['attribute_values']).to match_attributes expected_attribute_values
        end
      end

      context 'with some attributes override on the catalog product' do
        let(:expected_attribute_values) do
          { 'ungrouped' => [{ 'name' => 'CBD', 'value' => 'DEF' }, { 'name' => 'THC', 'value' => '2' }],
            'grouped' =>
          { 'MOODS' => [{ 'name' => 'Relaxed', 'value' => '1' }, { 'name' => 'Hungry', 'value' => '11' }],
            'Effects' => [{ 'name' => 'Anxious', 'value' => '0' }] } }
        end

        before do
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: group1_attribute2, value: '10')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute2, value: 'DEF')
          store_product.attribute_values << create(:attribute_value, attribute_def: group1_attribute2, value: '11', target: store_product)

          get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
        end

        it 'response include attributes' do
          expect(json['product']['attribute_values']).to match_attributes expected_attribute_values
        end
      end

      context 'with some attributes defined only on the product variant' do
        let!(:ungrouped_attribute3) { create :attribute_def, name: 'Copyright', attribute_group: nil }
        let!(:group2_attribute2) { create :attribute_def, name: 'Paranoid', attribute_group: group2 }
        let!(:group3) { create :attribute_group, name: 'Medical', order: 5 }
        let!(:group3_attribute) { create :attribute_def, name: 'Depression', attribute_group: group3 }

        let(:expected_attribute_values) do
          { 'ungrouped' => [{ 'name' => 'CBD', 'value' => 'ABC' }, { 'name' => 'Copyright', 'value' => 'Some copyright' }, { 'name' => 'THC', 'value' => '2' }],
            'grouped' =>
             { 'MOODS' => [{ 'name' => 'Relaxed', 'value' => '1' }, { 'name' => 'Hungry', 'value' => '5' }],
               'Effects' => [{ 'name' => 'Anxious', 'value' => '0' }, { 'name' => 'Paranoid', 'value' => 'no way!' }],
               'Medical' => [{ 'name' => 'Depression', 'value' => '.8' }] } }
        end

        before do
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: group2_attribute2, value: 'no way!')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: group3_attribute, value: '.8')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute3, value: 'Some copyright')

          get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
        end

        it 'response include attributes' do
          expect(json['product']['attribute_values']).to match_attributes expected_attribute_values
        end
      end

      context 'with some attributes defined only on the catalog product' do
        let!(:ungrouped_attribute3) { create :attribute_def, name: 'Copyright', attribute_group: nil }
        let!(:group2_attribute2) { create :attribute_def, name: 'Paranoid', attribute_group: group2 }
        let!(:group3) { create :attribute_group, name: 'Medical', order: 5 }
        let!(:group3_attribute) { create :attribute_def, name: 'Depression', attribute_group: group3 }

        let(:expected_attribute_values) do
          { 'ungrouped' => [{ 'name' => 'CBD', 'value' => 'ABC' }, { 'name' => 'Copyright', 'value' => 'Some copyright' }, { 'name' => 'THC', 'value' => '2' }],
            'grouped' =>
             { 'MOODS' => [{ 'name' => 'Relaxed', 'value' => '1' }, { 'name' => 'Hungry', 'value' => '5' }],
               'Effects' => [{ 'name' => 'Anxious', 'value' => '0' }, { 'name' => 'Paranoid', 'value' => 'no way!' }],
               'Medical' => [{ 'name' => 'Depression', 'value' => '.8' }] } }
        end

        before do
          store_product.attribute_values << build(:attribute_value, attribute_def: group2_attribute2, value: 'no way!')
          store_product.attribute_values << build(:attribute_value, attribute_def: group3_attribute, value: '.8')
          store_product.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute3, value: 'Some copyright')

          get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
        end

        it 'response include attributes' do
          expect(json['product']['attribute_values']).to match_attributes expected_attribute_values
        end
      end

      context 'with some attributes defined only on the product variant and other overiden' do
        let!(:ungrouped_attribute3) { create :attribute_def, name: 'Copyright', attribute_group: nil }
        let!(:group2_attribute2) { create :attribute_def, name: 'Paranoid', attribute_group: group2 }
        let!(:group3) { create :attribute_group, name: 'Medical', order: 5 }
        let!(:group3_attribute) { create :attribute_def, name: 'Depression', attribute_group: group3 }

        let(:expected_attribute_values) do
          { 'ungrouped' => [{ 'name' => 'CBD', 'value' => 'DEF' }, { 'name' => 'Copyright', 'value' => 'Some copyright' }, { 'name' => 'THC', 'value' => '2' }],
            'grouped' =>
             { 'MOODS' => [{ 'name' => 'Relaxed', 'value' => '1' }, { 'name' => 'Hungry', 'value' => '10' }],
               'Effects' => [{ 'name' => 'Anxious', 'value' => '0' }, { 'name' => 'Paranoid', 'value' => 'no way!' }],
               'Medical' => [{ 'name' => 'Depression', 'value' => '.8' }] } }
        end

        before do
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: group1_attribute2, value: '10')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute2, value: 'DEF')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: group2_attribute2, value: 'no way!')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: group3_attribute, value: '.8')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute3, value: 'Some copyright')

          get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
        end

        it 'response include attributes' do
          expect(json['product']['attribute_values']).to match_attributes expected_attribute_values
        end
      end

      context 'with some attributes defined only on the product variant and product and other overiden at catalog' do
        let!(:ungrouped_attribute3) { create :attribute_def, name: 'Copyright', attribute_group: nil }
        let!(:group2_attribute2) { create :attribute_def, name: 'Paranoid', attribute_group: group2 }
        let!(:group3) { create :attribute_group, name: 'Medical', order: 5 }
        let!(:group3_attribute) { create :attribute_def, name: 'Depression', attribute_group: group3 }

        let(:expected_attribute_values) do
          { 'ungrouped' => [{ 'name' => 'CBD', 'value' => 'DEF' }, { 'name' => 'Copyright', 'value' => 'Some copyright 2' }, { 'name' => 'THC', 'value' => '2' }],
            'grouped' =>
             { 'MOODS' => [{ 'name' => 'Relaxed', 'value' => '1' }, { 'name' => 'Hungry', 'value' => '5' }],
               'Effects' => [{ 'name' => 'Anxious', 'value' => '0' }, { 'name' => 'Paranoid', 'value' => 'no way! 2' }],
               'Medical' => [{ 'name' => 'Depression', 'value' => '.8 1' }] } }
        end

        before do
          store_product.product.attribute_values << build(:attribute_value, attribute_def: group2_attribute2, value: 'no way!')
          store_product.product.attribute_values << build(:attribute_value, attribute_def: group3_attribute, value: '.8')
          store_product.product.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute3, value: 'Some copyright')

          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: group2_attribute2, value: 'no way! 1')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: group3_attribute, value: '.8 1')
          store_product.product_variant.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute3, value: 'Some copyright 1')

          store_product.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute2, value: 'DEF')
          store_product.attribute_values << build(:attribute_value, attribute_def: group2_attribute2, value: 'no way! 2')
          store_product.attribute_values << build(:attribute_value, attribute_def: ungrouped_attribute3, value: 'Some copyright 2')

          get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
        end

        it 'response include attributes' do
          expect(json['product']['attribute_values']).to match_attributes expected_attribute_values
        end
      end
    end

    context 'with product layout' do
      let(:product_layout) { create :product_layout, stylesheet: 'some css' }
      let(:tab_1) { create :product_layout_tab, product_layout: product_layout, order: 2 }
      let(:tab_2) { create :product_layout_tab, product_layout: product_layout, order: 1 }
      let(:medium_element) { create :product_layout_medium, source: tab_1 }
      let(:dot_element) { create :product_layout_dot, source: tab_1 }
      let(:text_element) { create :product_layout_text, source: tab_2 }
      let(:common_medium) { create :product_layout_medium, source: product_layout }

      before { kiosk.layout.update!(product_layout: product_layout) }

      it 'response include layout' do
        kiosk_product.update!(stylesheet: 'product css')

        medium_value = create :product_layout_medium_value, kiosk_product: kiosk_product, product_layout_element: medium_element
        medium_value_2 = create :product_layout_medium_value, kiosk_product: kiosk_product, product_layout_element: common_medium
        dot_value = create :product_layout_dot_value, kiosk_product: kiosk_product, product_layout_element: dot_element
        text_value = create :product_layout_text_value, kiosk_product: kiosk_product, product_layout_element: text_element

        expected_layout = {
          stylesheet: "some css\nproduct css",
          common: product_layout_common_json([medium_value_2]),
          tabs: [
            product_layout_tab_json(tab_2, [text_value]),
            product_layout_tab_json(tab_1, [medium_value, dot_value])
          ]
        }.as_json

        get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)

        expect(json['product']['layout']).to eq expected_layout
      end

      it 'respond when layout has only tabs' do
        medium_value = create :product_layout_medium_value, kiosk_product: kiosk_product, product_layout_element: medium_element

        expected_layout = {
          stylesheet: 'some css',
          common: product_layout_common_json([]),
          tabs: [
            product_layout_tab_json(tab_1, [medium_value])
          ]
        }.as_json

        get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)

        expect(json['product']['layout']).to eq expected_layout
      end

      it 'respond when layout has only common' do
        medium_value_2 = create :product_layout_medium_value, kiosk_product: kiosk_product, product_layout_element: common_medium

        expected_layout = {
          stylesheet: 'some css',
          common: product_layout_common_json([medium_value_2]),
          tabs: []
        }.as_json

        get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)

        expect(json['product']['layout']).to eq expected_layout
      end

      it 'filter elements without value' do
        # create elements without value
        medium_element
        common_medium

        dot_value = create :product_layout_dot_value, kiosk_product: kiosk_product, product_layout_element: dot_element

        expected_layout = {
          stylesheet: 'some css',
          common: product_layout_common_json([]),
          tabs: [
            product_layout_tab_json(tab_1, [dot_value])
          ]
        }.as_json

        get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)

        expect(json['product']['layout']).to eq expected_layout
      end

      it 'return no layout without any value' do
        expected_layout = nil

        get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)

        expect(json['product']['layout']).to eq expected_layout
      end

      it 'filter values from other layouts (prevent errors)' do
        expected_layout = nil

        create :product_layout_medium_value, kiosk_product: kiosk_product
        create :product_layout_medium_value, :for_layout, kiosk_product: kiosk_product

        get api_v1_product_path(kiosk, store_product), headers: auth_headers(store)

        expect(json['product']['layout']).to eq expected_layout
      end
    end
  end

  describe 'product tags' do
    let(:product_variant) { create :product_variant }
    let(:store_product) { build :store_product, product_variant: product_variant, tag_list: 'tag1, tag2' }
    let!(:tag1) { create :tag_info, tag: 'tag1' }
    let!(:tag2) { create :tag_info, tag: 'tag2' }
    let!(:other_tag) { create :tag_info, tag: 'other_tag' }
    let(:expected_tags) { [tag1, tag2].map { |tag| tag.as_json(only: %i[tag description]).merge('created_at' => tag.created_at.iso8601(3), 'updated_at' => tag.updated_at.iso8601(3)) } }

    before do
      kiosk_product = create :kiosk_product, kiosk: kiosk, store_product: store_product
      store.store_categories[0].store_products << store_product
      get tags_api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
    end

    it 'respond with the tags descriptions' do
      expect(json['tags']).to eq expected_tags
    end
  end

  describe 'product reviews' do
    let(:product_variant) { create :product_variant }
    let(:store_product) { build :store_product, product_variant: product_variant }
    let!(:prod_review) { create :review, reviewable: product_variant.product }
    let!(:var_review1) { create :review, reviewable: product_variant }
    let!(:var_review2) { create :review, reviewable: product_variant }
    let!(:other_product_review) { create :review }
    let(:ordered_expected_reviews) { [prod_review, var_review1, var_review2].sort_by(&:created_at).reverse }
    let(:expected_reviews) { ordered_expected_reviews.map { |review| review.as_json(only: %i[user rate text]).merge('created_at' => review.created_at.iso8601(3), 'updated_at' => review.updated_at.iso8601(3)) } }

    before do
      kiosk_product = create :kiosk_product, kiosk: kiosk, store_product: store_product
      store.store_categories[0].store_products << store_product
      get reviews_api_v1_product_path(kiosk, store_product), headers: auth_headers(store)
    end

    it 'respond with the reviews' do
      expect(json['reviews']).to eq expected_reviews
    end
  end

  describe 'share' do
    let(:store_product) { create :store_product, store: store }
    let(:email) { 'anemail@mail.com' }
    let(:phone) { '1234' }
    let(:params) { { catalog_id: kiosk.id, id: store_product.id, share: { email: email } } }

    before do
      create :kiosk_product, kiosk: kiosk, store_product: store_product
    end

    it 'send email' do
      mailer_double = double
      allow(mailer_double).to receive(:deliver_now)

      expect(ProductsMailer).to receive(:share).with(store_product, email).and_return(mailer_double)

      post share_api_v1_product_path(kiosk, store_product), params: params, headers: auth_headers(store)

      expect(response).to have_http_status(:ok)
    end

    it 'send sms' do
      expect(ShareProductTextMessageJob).to receive(:perform_now).with(store_product, phone)

      post share_api_v1_product_path(kiosk, store_product), params: params.merge(share: { phone: phone }), headers: auth_headers(store)

      expect(response).to have_http_status(:ok)
    end

    it 'send email & sms' do
      mailer_double = double
      allow(mailer_double).to receive(:deliver_now)

      expect(ProductsMailer).to receive(:share).with(store_product, email).and_return(mailer_double)

      expect(ShareProductTextMessageJob).to receive(:perform_now).with(store_product, phone)

      post share_api_v1_product_path(kiosk, store_product), params: params.merge(share: { phone: phone, email: email }), headers: auth_headers(store)

      expect(response).to have_http_status(:ok)
    end

    it 'respond with  bad request without email and sms' do
      expect(ProductsMailer).not_to receive(:share)

      post share_api_v1_product_path(kiosk, store_product), params: params.except(:share), headers: auth_headers(store)

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'similar products', '
    If Flower type Indica that as a "Pain" tag:
    - Show us other Flower products with type Indica in -any- price range
    - Also show us Indica products in other categories in a similar price range
    - Also show us other products in other categories that match "Pain" tag
  ' do
    let(:flower) { create :store_category, store: store }
    let(:edibles) { create :store_category, store: store }
    let(:type_attr) { create :attribute_def, name: 'Type', attribute_group: nil }
    let(:thc_attr) { create :attribute_def, name: 'THC', attribute_group: nil }

    let(:indica_product) { create_product(type: 'indica') }
    let(:hybrid_product) { create_product(type: 'hybrid') }
    let(:indica_product_variant) { create_variant(product: indica_product) }
    let(:hybrid_product_variant) { create_variant(product: hybrid_product) }
    let(:indica_variant) { create_variant(product: hybrid_product, type: 'indica') }
    let(:hybrid_variant) { create_variant(product: indica_product, type: 'hybrid') }

    let!(:flower_indica_store_products) do
      [
        create(:store_product, product_variant: indica_variant, store_category: flower, tag_list: 'tag1'),
        create(:store_product, product_variant: indica_product_variant, store_category: flower)
      ]
    end
    let!(:flower_hybrid_store_products) do
      [
        create(:store_product, product_variant: hybrid_variant, store_category: flower),
        create(:store_product, product_variant: hybrid_product_variant, store_category: flower)
      ]
    end

    let!(:edibles_indica_with_same_price) do
      [
        create(:store_product, product_variant: indica_variant, store_category: edibles, tag_list: 'tag1', prices: { OMMP: 14, REC: 19.2 }).reload,
        create(:store_product, product_variant: indica_product_variant, store_category: edibles, prices: { OMMP: 8, REC: 12.5 }).reload
      ]
    end
    let!(:edibles_indica_with_other_price) do
      [
        create(:store_product, product_variant: indica_product_variant, store_category: edibles, prices: { "": 7.99, REC: 19.21 }).reload
      ]
    end

    let!(:edibles_with_same_tags) do
      [
        create(:store_product, product_variant: hybrid_variant, store_category: edibles, tag_list: 'tag1, tag4').reload,
        create(:store_product, product_variant: indica_variant, store_category: edibles, tag_list: 'tag1, tag2').reload
      ]
    end
    let!(:edibles_with_other_tags) do
      [
        create(:store_product, store_category: edibles, tag_list: 'tag3')
      ]
    end

    let(:variant) { create_variant product: indica_product }
    let(:prices) { { "": 10, REC: 16 } }
    let(:tags) { 'tag1, tag2' }

    before do
      store.store_products.each do |sp|
        create :kiosk_product, kiosk: kiosk, store_product: sp
      end
    end

    context 'when product has prices and tags' do
      let(:store_product) { create :store_product, store_category: flower, product_variant: variant, tag_list: tags, prices: prices }
      let(:expected_products) do
        (
        flower_indica_store_products.reverse +
        edibles_indica_with_same_price.reverse +
        edibles_with_same_tags.reverse
      ).map { |p| kiosk_product_json(p.reload.kiosk_products.first) }
      end

      before do
        create :kiosk_product, kiosk: kiosk, store_product: store_product
      end

      it 'respond with products with same category and type, then same type and price, then same tags' do
        get similars_api_v1_product_path(kiosk, store_product), headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 6
        expect(json['products']).to match_products expected_products
        expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 6, 'total_pages' => 1)
      end

      it 'should be able to paginate results' do
        get similars_api_v1_product_path(kiosk, store_product), headers: auth_headers(store), params: { page: 2, per_page: 3 }

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 3
        expect(json['products']).to match_products expected_products.last(3)
        expect(json['meta']).to eq('current_page' => 2, 'next_page' => nil, 'prev_page' => 1, 'total_count' => 6, 'total_pages' => 2)
      end

      it 'should ignore products from other catalogs' do
        create :store_product, product_variant: indica_variant, prices: prices
        create :store_product, product_variant: hybrid_variant, tag_list: 'tag1, tag2'

        get similars_api_v1_product_path(kiosk.id, store_product.id), headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 6
        expect(json['products']).to match_products expected_products
        expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 6, 'total_pages' => 1)
      end

      context 'ordering by name' do
        let(:expected_products) do
          (
            flower_indica_store_products.sort_by(&:name_for_catalog) +
            edibles_indica_with_same_price.sort_by(&:name_for_catalog) +
            edibles_with_same_tags.sort_by(&:name_for_catalog)
          ).map { |p| kiosk_product_json(p.reload.kiosk_products.first) }
        end
        let(:params) { { sort_by: :name, sort_direction: :asc } }

        it 'should first sort by rule precedence and then by name' do
          get similars_api_v1_product_path(kiosk, store_product), headers: auth_headers(store), params: params

          expect(json).to have_key('products')
          expect(json['products'].count).to eq 6
          expect(json['products']).to match_products expected_products
          expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 6, 'total_pages' => 1)
        end
      end
    end

    context 'when product has tags but no prices' do
      let(:store_product) { create :store_product, store_category: flower, product_variant: variant, tag_list: tags }
      let(:expected_products) do
        (
        flower_indica_store_products.reverse +
        edibles_with_same_tags.reverse +
        edibles_indica_with_same_price.first(1)
      ).map { |p| kiosk_product_json(p.reload.kiosk_products.first) }
      end

      before do
        create :kiosk_product, kiosk: kiosk, store_product: store_product
      end

      it 'respond just with products with same category and type, then same tags' do
        get similars_api_v1_product_path(kiosk, store_product), headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 5
        expect(json['products']).to match_products expected_products
        expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 5, 'total_pages' => 1)
      end
    end

    context 'when product has prices but no tags' do
      let(:store_product) { create :store_product, store_category: flower, product_variant: variant, prices: prices }
      let(:expected_products) do
        (
        flower_indica_store_products.reverse +
        edibles_indica_with_same_price.reverse
      ).map { |p| kiosk_product_json(p.reload.kiosk_products.first) }
      end

      before do
        create :kiosk_product, kiosk: kiosk, store_product: store_product
      end

      it 'respond just with products with same category and type, then same type and price' do
        get similars_api_v1_product_path(kiosk.id, store_product.id), headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 4
        expect(json['products']).to match_products expected_products
        expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 4, 'total_pages' => 1)
      end
    end

    context "when product doesn't have tags and prices" do
      let(:store_product) { create :store_product, store_category: flower, product_variant: variant }
      let(:expected_products) { flower_indica_store_products.reverse.map { |p| kiosk_product_json(p.reload.kiosk_products.first) } }

      before do
        create :kiosk_product, kiosk: kiosk, store_product: store_product
      end

      it 'respond just with products with same category and type' do
        get similars_api_v1_product_path(kiosk, store_product.id), headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 2
        expect(json['products']).to match_products expected_products
        expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 2, 'total_pages' => 1)
      end
    end

    context 'when product has no type' do
      let(:store_product) { create :store_product, store_category: flower, tag_list: tags }
      let(:expected_products) do
        (
        edibles_with_same_tags.reverse +
        edibles_indica_with_same_price.first(1) +
        flower_indica_store_products.first(1)
      ).map { |p| kiosk_product_json(p.reload.kiosk_products.first) }
      end

      before do
        create :kiosk_product, kiosk: kiosk, store_product: store_product
      end

      it 'respond just with products with the same tags' do
        get similars_api_v1_product_path(kiosk, store_product.id), headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 4
        expect(json['products']).to match_products expected_products
        expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 4, 'total_pages' => 1)
      end
    end

    context 'minimal response' do
      let(:store_product) { create :store_product, store_category: flower, tag_list: tags }
      let(:expected_products) do
        (
        edibles_with_same_tags.reverse +
        edibles_indica_with_same_price.first(1) +
        flower_indica_store_products.first(1)
      ).map { |p| p.reload.kiosk_products.first.store_product.id }
      end

      before do
        create :kiosk_product, kiosk: kiosk, store_product: store_product
      end

      it 'respond just with products with the same tags' do
        get similars_api_v1_product_path(kiosk, store_product.id, minimal: true), headers: auth_headers(store)

        expect(json).to have_key('products')
        expect(json['products'].count).to eq 4
        expect(json['products']).to eq expected_products
        expect(json['meta']).to eq('current_page' => 1, 'next_page' => nil, 'prev_page' => nil, 'total_count' => 4, 'total_pages' => 1)
      end
    end

    def create_product(type: 'indica', thc: '0.56')
      create(:product).tap do |object|
        if type.present?
          object.attribute_values << build(:attribute_value, attribute_def: type_attr, value: type)
        end
        if thc.present?
          object.attribute_values << build(:attribute_value, attribute_def: thc_attr, value: thc)
        end
      end
    end

    def create_variant(product:, type: nil, thc: '0.56')
      create(:product_variant, product: product).tap do |object|
        if type.present?
          object.attribute_values << build(:attribute_value, attribute_def: type_attr, value: type)
        end
        if thc.present?
          object.attribute_values << build(:attribute_value, attribute_def: thc_attr, value: thc)
        end
      end
    end
  end
end
