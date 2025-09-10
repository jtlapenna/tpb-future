require 'rails_helper'

describe StoreProduct do
  let(:store_product) { build_stubbed :store_product }

  it 'is valid' do
    expect(store_product).to be_valid
  end

  it 'is not valid without category' do
    store_product.store_category = nil
    expect(store_product).not_to be_valid
  end

  it 'is not valid without product variant' do
    store_product.product_variant = nil
    expect(store_product).not_to be_valid
  end

  it 'stock is 0 by default' do
    expect(StoreProduct.new.stock).to eq 0
  end

  it 'is not valid without stock' do
    store_product.stock = nil
    expect(store_product).not_to be_valid
  end

  it 'is not valid without sku' do
    store_product.sku = nil
    expect(store_product).not_to be_valid
    expect(store_product.errors[:sku]).to eq ["can't be blank"]
  end

  it 'is not valid with more than 160 caracters as share_sms_template' do
    store_product.share_sms_template = nil
    expect(store_product).to be_valid

    store_product.share_sms_template = 160.times.map { 'a' }.join
    expect(store_product).to be_valid

    store_product.share_sms_template = 161.times.map { 'a' }.join
    expect(store_product).not_to be_valid
    expect(store_product.errors[:share_sms_template]).to eq ['is too long (maximum is 160 characters)']
  end

  it 'should only validate share_sms_template when it changes' do
    store_product = create :store_product
    store_product.update_columns share_sms_template: 161.times.map { 'a' }.join

    expect(store_product.reload).to be_valid
  end

  it 'sanitize override tags flag' do
    store_product.override_tags = nil

    expect do
      store_product.valid?
    end.to change {
      store_product.override_tags
    }.from(nil).to(false)

    store_product.override_tags = nil
    expect do
      store_product.override_tags = true
      store_product.valid?
    end.to change {
      store_product.override_tags
    }.from(nil).to(true)
  end

  it 'denormalize store_id before validation' do
    store_id = store_product.store_category.store_id
    expect do
      store_product.valid?
    end.to change {
      store_product.store_id
    }.from(nil).to(store_id)
  end

  it 'is not valid with negative stock' do
    store_product.stock = -1
    expect(store_product).not_to be_valid
    expect(store_product.errors[:stock]).to eq ['must be greater than or equal to 0']
  end

  context 'sku' do
    let!(:store_product) { create :store_product }
    let(:another_product) { build :store_product, sku: store_product.sku, store_category: store_product.store_category }

    it 'sku is unique' do
      expect(another_product).not_to be_valid
      expect(another_product.errors[:sku]).to eq ['has already been taken']
    end
  end

  context 'images' do
    let(:image) { create :image }
    let(:product) { image.imageable }
    let(:variant) { create :product_variant, product: product }
    let(:store_product) { create :store_product, product_variant: variant }

    before do
      variant.images << image
    end

    it 'can add image from product' do
      expect do
        store_product.images << image
      end.to change {
        store_product.images.count
      }.from(1).to 2
    end

    it 'can not add an image from another product' do
      expect do
        store_product.images << create(:image)
      end.to raise_error 'Only images from parent product are allowed'
    end

    it 'can add primary image' do
      store_product.images << image
      store_product.reload.primary_image_id = image.id
      store_product.save
      expect(store_product.reload.primary_image).to be
    end

    it 'can not add primary image that is not on the product' do
      expect do
        store_product.primary_image_id = create(:image).id
        store_product.save!
      end.to raise_error 'Primary image should belongs to this product'
    end

    it 'can add thumb image' do
      store_product.images << image
      store_product.reload.thumb_image_id = image.id
      store_product.save
      expect(store_product.reload.thumb_image).to be
    end

    it 'can not add thumb image that is not on the product' do
      expect do
        store_product.thumb_image_id = create(:image).id
        store_product.save!
      end.to raise_error 'Thumb image should belongs to this product'
    end

    it 'can add a thumb image that belongs to store product' do
      img = create(:image, imageable: store_product)

      store_product.reload.primary_image_id = img.id
      store_product.save!
      expect(store_product.reload.primary_image).to eq(img)
    end

    it 'can add a primary image that belongs to store product' do
      img = create(:image, imageable: store_product)

      store_product.reload.thumb_image_id = img.id
      store_product.save!
      expect(store_product.reload.thumb_image).to eq(img)
    end
  end

  context 'versioning', versioning: true do
    let(:store_product) { create :store_product }

    it 'do not create a version on create' do
      expect(store_product.versions.count).to eq 0
    end

    it 'create a version on update stock' do
      store_product.update!(stock: 10)

      expect(store_product.versions.count).to eq 1
      expect(store_product.paper_trail.previous_version.stock).to eq 0
    end
  end

  context 'tags' do
    let(:product) { create :product, tag_list: 'master 1, master 2' }
    let(:variant) { create :product_variant, tag_list: 'variant 1, variant 2', product: product }
    let(:store_product) { create :store_product, product_variant: variant, tag_list: 'cp 1, cp 2' }

    before { store_product.reload }

    it 'return all tags' do
      expect(store_product.products_tags).to match_array ['cp 1', 'cp 2', 'variant 1', 'variant 2', 'master 1', 'master 2']
    end

    context 'when catalog product override tags' do
      let(:store_product) { create :store_product, product_variant: variant, tag_list: 'cp 1, cp 2', override_tags: true }

      it 'only return catalog products tags' do
        expect(store_product.products_tags).to match_array ['cp 1', 'cp 2']
      end
    end

    context 'when variant override tags but catalog product does not' do
      let(:variant) { create :product_variant, tag_list: 'variant 1, variant 2', product: product, override_tags: true }

      it 'return catalog products tags, and vatiant tags' do
        expect(store_product.products_tags).to match_array ['cp 1', 'cp 2', 'variant 1', 'variant 2']
      end
    end

    context 'when variant and catalog override tags' do
      let(:variant) { create :product_variant, tag_list: 'variant 1, variant 2', product: product, override_tags: true }
      let(:store_product) { create :store_product, product_variant: variant, tag_list: 'cp 1, cp 2', override_tags: true }

      it 'return catalog products tags' do
        expect(store_product.products_tags).to match_array ['cp 1', 'cp 2']
      end
    end
  end

  context '#deep_tagged_with' do
    let(:tag) { 'cbd' }
    let(:products) { described_class.deep_tagged_with(tag) }

    before do
      @cbd_product           = create :product, tag_list: 'cbd, thc'
      @cbd_variant_product   = create :product_variant, tag_list: 'cbd, thc', product: @cbd_product
      @cbd_store_product = create :store_product, tag_list: 'cbd, thc', product_variant: @cbd_variant_product

      @thc_product         = create :product, tag_list: 'thc'
      @thc_variant_product = create :product_variant, tag_list: 'thc', product: @thc_product
      @thc_store_product = create :store_product, tag_list: 'thc', product_variant: @thc_variant_product
    end

    it 'includes catalog product tagged with cbd' do
      expect(products.count).to eq 1
      expect(products).to eq [@cbd_store_product]
    end

    it 'includes variants tagged with cbd' do
      other_store_product = create :store_product, tag_list: 'thc', product_variant: @cbd_variant_product

      expect(products.count).to eq 2
      expect(products).to eq [@cbd_store_product, other_store_product]
    end

    it 'includes products tagged with the tag' do
      other_variant_product = create :product_variant, tag_list: 'thc', product: @cbd_product
      other_store_product = create :store_product, tag_list: 'thc', product_variant: other_variant_product

      expect(products.count).to eq 2
      expect(products).to match_array [@cbd_store_product, other_store_product]
    end

    context 'thc products' do
      let(:tag) { 'thc' }

      it 'includes catalog product tagged with thc' do
        expect(products.count).to eq 2
        expect(products).to match_array [@cbd_store_product, @thc_store_product]
      end
    end

    context 'overrides' do
      let(:tag) { 'thc' }

      before do
        # This should not be oncluded, even if variant includes the thc tag
        @other_product_1 = create :store_product, tag_list: 'new tag', product_variant: @thc_variant_product, override_tags: true

        # This should not be oncluded, even if master includes the thc tag
        variant = create :product_variant, tag_list: 'variant 1', product: @thc_product, override_tags: true
        @other_product_2 = create :store_product, tag_list: 'new tag 2', product_variant: variant
      end

      it 'do not include variants if catalog overrides' do
        expect(products.count).to eq 2
        expect(products).to match_array [@cbd_store_product, @thc_store_product]
      end

      context 'asking for variants that overrides tags' do
        let(:tag) { 'new tag 2' }

        it 'include products with the tag' do
          expect(products.count).to eq 1
          expect(products).to match_array [@other_product_2]
        end
      end

      context 'asking for catalog products that overrides tags' do
        let(:tag) { 'new tag' }

        it 'include products with the tag' do
          expect(products.count).to eq 1
          expect(products).to match_array [@other_product_1]
        end
      end

      context 'asking for tag from variant' do
        let(:tag) { 'variant 1' }

        it 'include products with the tag' do
          expect(products.count).to eq 1
          expect(products).to match_array [@other_product_2]
        end
      end

      context 'asking for variants that overrides tags' do
        let(:tag) { 'thc' }

        it 'include products with the tag' do
          expect(products.count).to eq 2
          expect(products).to match_array [@cbd_store_product, @thc_store_product]
        end
      end
    end
  end

  context '#destroy' do
    let(:store_product) { create :store_product }

    it 'should destroy rfids, attributes values, videos, product values, kiosk products and own images' do
      create :attribute_value, target: store_product
      create :product_value, valuable: store_product
      create :asset, source: store_product
      create :kiosk_product, store_product: store_product
      create :image, imageable: store_product

      store_product.destroy

      expect(AttributeValue.count).to eq 0
      expect(ProductValue.count).to eq 0
      expect(Asset.count).to eq 0
      expect(KioskProduct.count).to eq 0
      expect(Image.count).to eq 0
    end

    it 'should remove catalog product from catalog article' do
      article = create :store_article, store: store_product.store
      article.store_products << create(:store_product, store: article.store)
      article.store_products << store_product

      expect { store_product.destroy }.to change { article.reload.store_product_ids }
    end

    it 'should not destroy primary image, thumb image nor images' do
      image = create :image, imageable: store_product.product_variant.product
      store_product.product_variant.images << image

      store_product.images << image
      store_product.reload.update! primary_image_id: image, thumb_image: image

      store_product.destroy

      expect(Image.count).to eq 1
    end
  end

  context 'with brand' do
    let(:brand_1) { create :brand }
    let(:brand_2) { create :brand }
    let(:product_variant) { create :product_variant, brand: variant_brand }
    let(:store_product) { create :store_product, product_variant: product_variant, brand: catalog_brand }

    before { store_product.touch }

    context 'when variant has brand and catalog product not' do
      let(:variant_brand) { brand_1 }
      let(:catalog_brand) { nil }

      it 'return products count' do
        expect(StoreProduct.by_brand(brand_1.id).count).to eq 1
        expect(StoreProduct.by_brand(brand_2.id).count).to eq 0
      end
    end

    context 'when variant has brand and catalog product has the same' do
      let(:variant_brand) { brand_1 }
      let(:catalog_brand) { brand_1 }

      it 'return products count' do
        expect(StoreProduct.by_brand(brand_1.id).count).to eq 1
        expect(StoreProduct.by_brand(brand_2.id).count).to eq 0
      end
    end

    context 'when variant has brand and catalog product has another' do
      let(:variant_brand) { brand_1 }
      let(:catalog_brand) { brand_2 }

      it 'return products count' do
        expect(StoreProduct.by_brand(brand_1.id).count).to eq 0
        expect(StoreProduct.by_brand(brand_2.id).count).to eq 1
      end
    end

    context 'when no brands' do
      let(:variant_brand) { nil }
      let(:catalog_brand) { nil }

      it 'return products count' do
        expect(StoreProduct.by_brand(brand_1.id).count).to eq 0
        expect(StoreProduct.by_brand(brand_2.id).count).to eq 0
      end
    end

    context 'when no brands' do
      let(:variant_brand) { nil }
      let(:catalog_brand) { brand_1 }

      it 'return products count' do
        expect(StoreProduct.by_brand(brand_1.id).count).to eq 1
        expect(StoreProduct.by_brand(brand_2.id).count).to eq 0
      end
    end
  end

  context 'auto-import to kiosk' do
    let(:store) { create :store }
    let(:brand_1) { create :brand }
    let(:brand_2) { create :brand }
    let(:category_1) { create :store_category, store: store }
    let(:category_2) { create :store_category, store: store }
    let(:variant_with_brand) { create :product_variant, brand: brand_1 }

    context '#creating' do
      it 'auto add to kiosks that match criteria' do
        kiosk_none        = create(:kiosk, store: store, product_filter_criteria: :custom)
        kiosk_all         = create(:kiosk, store: store, product_filter_criteria: :all)
        kiosk_brand_1     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_1)
        kiosk_brand_2     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_2)
        kiosk_category_1  = create(:kiosk, store: store, product_filter_criteria: :category, product_filter_value: category_1)
        kiosk_category_2  = create(:kiosk, store: store, product_filter_criteria: :category, product_filter_value: category_2)

        # Start with 0 products
        expect(KioskProduct.count).to eq 0

        product_1 = create :store_product, store: store, brand: brand_1, store_category: category_2, status: :unpublished
        product_2 = create :store_product, store: store, brand: nil, product_variant: variant_with_brand, store_category: category_1
        product_3 = create :store_product, store: store, store_category: category_1

        expect(kiosk_none.kiosk_products.map(&:store_product)).to eq []
        expect(kiosk_all.kiosk_products.map(&:store_product)).to match_array [product_1, product_2, product_3]
        expect(kiosk_brand_1.kiosk_products.map(&:store_product)).to match_array [product_1, product_2]
        expect(kiosk_brand_2.kiosk_products.map(&:store_product)).to match_array []
        expect(kiosk_category_1.kiosk_products.map(&:store_product)).to match_array [product_2, product_3]
        expect(kiosk_category_2.kiosk_products.map(&:store_product)).to match_array [product_1]
      end
    end

    context '#updating' do
      let(:kiosk) { create(:kiosk, store: store, product_filter_criteria: :custom) }

      it 'change kiosk when product brand change' do
        kiosk_brand_1     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_1)
        kiosk_brand_2     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_2)

        product_1 = create :store_product, store: store, brand: brand_1, store_category: category_1

        product_1.update!(brand: brand_2)

        expect(kiosk_brand_1.kiosk_products.map(&:store_product)).to match_array []
        expect(kiosk_brand_2.kiosk_products.map(&:store_product)).to match_array [product_1]
      end

      it 'change kiosk when product brand change to be delegated to variant' do
        kiosk_brand_1     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_1)
        kiosk_brand_2     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_2)

        variant = create :product_variant, brand: brand_2
        product_1 = create :store_product, store: store, brand: brand_1, store_category: category_1, product_variant: variant

        product_1.update!(brand: nil)

        expect(kiosk_brand_1.kiosk_products.map(&:store_product)).to match_array []
        expect(kiosk_brand_2.kiosk_products.map(&:store_product)).to match_array [product_1]
      end

      it 'change kiosk when product brand stop being delegate to variant' do
        kiosk_brand_1     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_1)
        kiosk_brand_2     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_2)

        variant = create :product_variant, brand: brand_1
        product_1 = create :store_product, store: store, brand: nil, store_category: category_1, product_variant: variant

        product_1.update!(brand: brand_2)

        expect(kiosk_brand_1.kiosk_products.map(&:store_product)).to match_array []
        expect(kiosk_brand_2.kiosk_products.map(&:store_product)).to match_array [product_1]
      end

      it 'change kiosk when product category change' do
        kiosk_category_1  = create(:kiosk, store: store, product_filter_criteria: :category, product_filter_value: category_1)
        kiosk_category_2  = create(:kiosk, store: store, product_filter_criteria: :category, product_filter_value: category_2)

        product_1 = create :store_product, store: store, store_category: category_1

        product_1.update!(store_category: category_2)

        expect(kiosk_category_1.kiosk_products.map(&:store_product)).to match_array []
        expect(kiosk_category_2.kiosk_products.map(&:store_product)).to match_array [product_1]
      end
    end
  end
end
