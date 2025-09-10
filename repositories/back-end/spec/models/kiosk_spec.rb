require 'rails_helper'

describe Kiosk do
  let(:kiosk) { build_stubbed :kiosk }

  it 'is valid' do
    expect(kiosk).to be_valid
  end

  it 'is active' do
    expect(Kiosk.new.active).to be
  end

  it 'is not valid without name' do
    kiosk.name = nil
    expect(kiosk).not_to be_valid
  end

  it 'is not valid without store' do
    kiosk.store = nil
    expect(kiosk).not_to be_valid
  end

  it 'is not valid with non numberic sensor threshold' do
    kiosk.sensor_threshold = 12
    expect(kiosk).to be_valid

    kiosk.sensor_threshold = 'a12'
    expect(kiosk).not_to be_valid
  end

  it 'is not valid with non numberic sensor method is not rfid or us' do
    kiosk.sensor_method = 'rfid'
    expect(kiosk).to be_valid

    kiosk.sensor_method = 'us'
    expect(kiosk).to be_valid

    kiosk.sensor_method = 'nfc'
    expect(kiosk).to be_valid

    kiosk.sensor_method = 'xx'
    expect(kiosk).not_to be_valid
  end

  context 'exist tags for 2 kiosks (own tags, product, product variant and kiosk product)' do
    let(:store) { create :store }
    let(:kiosk) { create :kiosk, store: store }
    let(:store_product) { create :store_product, store: store }
    let(:product_variant) { store_product.product_variant }
    let(:product) { product_variant.product }

    let(:store2) { create :store }
    let(:kiosk2) { create :kiosk, store: store2 }
    let(:store_product2) { create :store_product }
    let(:product_variant2) { store_product2.product_variant }
    let(:product2) { product_variant2.product }

    before do
      (1..10).each { |n| ActsAsTaggableOn::Tag.create!(name: "tag-#{n}") } # tags randoms alone

      create :kiosk_product, store_product: store_product, kiosk: kiosk
      create :kiosk_product, store_product: store_product2, kiosk: kiosk2

      store_product.tag_list.add('tag-catalog-product', 'tag-catalog-product-2', 'tag-product') && store_product.save!
      product_variant.tag_list.add('tag-product-variant', 'tag-product-variant-2', 'tag-product', 'tag-product-variant') && product_variant.save!
      # some tags repeatead, but should appear once
      product.tag_list.add('tag-product', 'tag-product-2') && product.save!
      kiosk.tag_list.add('tag-catalog', 'tag-catalog-2') && kiosk.save!

      store_product2.tag_list.add('catalog-2-tag-catalog-product', 'catalog-2-tag-catalog-product-2', 'tag-product') && store_product2.save!
      product_variant2.tag_list.add('catalog-2-tag-product-variant', 'catalog-2-tag-product-variant-2') && product_variant2.save!
      product2.tag_list.add('catalog-2-tag-product', 'catalog-2-tag-product-2') && product2.save!
      kiosk2.tag_list.add('catalog-2-tag-catalog', 'catalog-2-tag-catalog-2') && kiosk2.save!
    end

    it 'get all tags for one catalog' do
      expected_tags = %w[tag-catalog tag-catalog-2
                         tag-catalog-product tag-catalog-product-2
                         tag-product tag-product-2
                         tag-product-variant tag-product-variant-2]
      expect(kiosk.products_tags.name_like('a').map(&:name).sort).to eq expected_tags
    end

    it 'get no repetead tags' do
      expect(kiosk.products_tags.name_like('a').map(&:name).count).to eq 8
    end
  end

  context 'brands' do
    let(:kiosk) { build :kiosk }
    let(:store) { kiosk.store }
    let(:variant_no_brand) { build :product_variant, brand: nil }
    let(:variant_with_brand) { build :product_variant, brand: brands[0] }
    let(:brands) do
      6.times.map { |i| create :brand, name: "brand #{i}" }
    end

    before do
      # This should not count
      create_list :brand, 2
      # This should not count (another kiosk)
      create :store_product, brand: create(:brand), stock: 1, status: :published

      # +0 brands
      store_product_1 = create :store_product, store: store, product_variant: variant_no_brand, brand: nil, stock: 1, status: :published
      kiosk.store_products << store_product_1

      # +1 brand
      store_product_2 = create :store_product, store: store, product_variant: variant_no_brand, brand: brands[1], stock: 1, status: :published
      kiosk.store_products << store_product_2

      # +1 brand
      store_product_3 = create :store_product, store: store, product_variant: variant_with_brand, brand: nil, stock: 1, status: :published
      kiosk.store_products << store_product_3

      # +1 brand (from variant default)
      store_product_4 = create :store_product, store: store, brand: nil, stock: 1, status: :published
      kiosk.store_products << store_product_4

      # 0 brands
      store_product_5 = create :store_product, store: store, product_variant: variant_with_brand, brand: brands[0], stock: 1, status: :published
      kiosk.store_products << store_product_5

      # +1 brands
      store_product_6 = create :store_product, store: store, product_variant: variant_with_brand, brand: brands[2], stock: 1, status: :published
      kiosk.store_products << store_product_6

      # +1 brand (new variant and kiosk brand)
      store_product_7 = create :store_product, store: store, brand: brands[3], stock: 1, status: :published
      kiosk.store_products << store_product_7

      # 0 brand (without stock)
      store_product_8 = create :store_product, store: store, product_variant: variant_with_brand, brand: brands[4], stock: 0, status: :published
      kiosk.store_products << store_product_8

      # 0 brand (not published)
      store_product_9 = create :store_product, store: store, product_variant: variant_with_brand, brand: brands[5], stock: 1, status: :unpublished
      kiosk.store_products << store_product_9

      kiosk.save!
    end

    it 'return kiosks brands' do
      expect(kiosk.brands.count).to eq 5
    end
  end

  context 'filter products' do
    let(:store) { create :store }
    let(:brand_1) { create :brand }
    let(:brand_2) { create :brand }
    let(:category_1) { create :store_category, store: store }
    let(:category_2) { create :store_category, store: store }
    let(:variant_with_brand) { create :product_variant, brand: brand_1 }
    let!(:store_product_1) { create :store_product, store_category: category_1, brand: nil, product_variant: variant_with_brand, status: :published }
    let!(:store_product_2) { create :store_product, store_category: category_1, brand: brand_1, status: :unpublished }
    let!(:store_product_3) { create :store_product, store_category: category_1, brand: brand_2 }
    let!(:store_product_4) { create :store_product, store_category: category_2, brand: nil }

    context '#creating' do
      it 'add no product when criteria is custom' do
        kiosk = create(:kiosk, store: store, product_filter_criteria: :custom)

        expected = []

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
      end

      it 'add all products when criteria is all' do
        kiosk = create(:kiosk, store: store, product_filter_criteria: :all)

        expected = [store_product_1, store_product_2, store_product_3, store_product_4]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
      end

      it 'add category_1 products when criteria is category' do
        kiosk = create(:kiosk, store: store, product_filter_criteria: :category, product_filter_value: category_1)

        expected = [store_product_1, store_product_2, store_product_3]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
      end

      it 'add brand products when criteria is brand' do
        kiosk = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_1)

        expected = [store_product_1, store_product_2]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
      end
    end

    context '#updating criteria' do
      let(:kiosk) { create(:kiosk, store: store, product_filter_criteria: :custom) }

      it 'add products when criteria change to all' do
        kiosk.update!(product_filter_criteria: :all)

        expected = [store_product_1, store_product_2, store_product_3, store_product_4]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
      end

      it 'add products when criteria change to category' do
        kiosk.update!(product_filter_criteria: :category, product_filter_value: category_1)

        expected = [store_product_1, store_product_2, store_product_3]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
      end

      it 'add products when criteria change to brand' do
        kiosk.update!(product_filter_criteria: :brand, product_filter_value: brand_1)

        expected = [store_product_1, store_product_2]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
      end

      it 'preserve existing products' do
        kiosk.kiosk_products.create! store_product: store_product_1, featured: true

        kiosk.update!(product_filter_criteria: :all)

        expected = [store_product_1, store_product_2, store_product_3, store_product_4]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
        expect(kiosk.kiosk_products.first).to be_featured
        expect(kiosk.kiosk_products.second).not_to be_featured
      end

      it "remove products that don't match new criteria" do
        kiosk.kiosk_products.create! store_product: store_product_4

        kiosk.update!(product_filter_criteria: :brand, product_filter_value: brand_1)

        expected = [store_product_1, store_product_2]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
      end
    end

    context '#updating criteria to custom' do
      let(:kiosk) { create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_1) }

      it 'keep existing products' do
        kiosk.kiosk_products.first.update! featured: true

        kiosk.update!(product_filter_criteria: :custom)

        expected = [store_product_1, store_product_2]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
        expect(kiosk.kiosk_products.first).to be_featured
      end
    end

    context '#updating value' do
      let(:kiosk) { create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_2) }

      it 'change kiosk products' do
        kiosk.update!(product_filter_criteria: :brand, product_filter_value: brand_1)

        expected = [store_product_1, store_product_2]

        expect(kiosk.reload.kiosk_products.count).to eq expected.size
        expect(kiosk.reload.kiosk_products.map(&:store_product)).to match_array expected
      end
    end
  end
end
