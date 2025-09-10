require 'rails_helper'

describe ProductVariant do
  let(:variant) { build_stubbed :product_variant }

  it 'is valid' do
    expect(variant).to be_valid
  end

  it 'is valid without an sku' do
    create :product_variant, sku: nil

    variant.sku = nil
    expect(variant).to be_valid
  end

  it 'is not valid without product' do
    variant.product = nil
    expect(variant).not_to be_valid
    expect(variant.errors[:product]).to eq ['must exist']
  end

  it 'sanitize override tags flag' do
    variant.override_tags = nil

    expect do
      variant.valid?
    end.to change {
      variant.override_tags
    }.from(nil).to(false)

    variant.override_tags = nil
    expect do
      variant.override_tags = true
      variant.valid?
    end.to change {
      variant.override_tags
    }.from(nil).to(true)
  end

  describe 'sku' do
    let(:variant) { create :product_variant }

    it 'should be unique' do
      another_product = build :product_variant, sku: variant.sku
      expect(another_product).not_to be_valid
      expect(another_product.errors[:sku]).to eq ['has already been taken']
    end
  end

  describe 'name' do
    let(:product) { build :product, name: 'Product 1' }
    let(:variant) { build :product_variant, name: nil, product: product }

    it 'is valid without name' do
      expect(variant).to be_valid
    end

    it 'empty name is set to nil' do
      variant.name = ''
      expect do
        variant.save!
      end.to change {
        variant.name
      }.from('').to nil
    end

    it 'blank name is set to nil' do
      variant.name = '   '
      expect do
        variant.save!
      end.to change {
        variant.name
      }.from('   ').to nil
    end
  end

  context 'category' do
    let(:category) { build_stubbed :category }
    let(:product) { build_stubbed :product, category: category }
    let(:variant) { build_stubbed :product_variant, product: product }

    it 'take category from product' do
      expect(variant.category).to eq category
    end
  end

  context 'images' do
    let(:image_1) { create :image }
    let(:product) { image_1.imageable }
    let(:variant) { create :product_variant, product: product }
    let(:image_2) { build(:image) }

    before do
      product.images << image_2
    end

    it 'can add image from product' do
      expect do
        variant.images << image_1
      end.to change {
        variant.images.count
      }.from(1).to 2
    end

    it 'can not add image from another product' do
      expect do
        variant.images << create(:image)
      end.to raise_error 'Only images from parent product are allowed'
    end

    context 'removing images' do
      let(:store_products) { create_list :store_product, 2, product_variant: variant }

      before do
        variant.images << image_1 unless variant.images.include?(image_1)
        variant.images << image_2 unless variant.images.include?(image_2)
        store_products[0].images << image_2
        store_products[1].images << image_2
      end

      it 'remove images on store products' do
        expect do
          variant.update(image_ids: [image_1.id])
        end.to change {
          store_products.map { |cp| cp.images.count }.flatten
        }.from([2, 2]).to [1, 1]
      end

      it 'remove images on store products when no images left' do
        expect do
          variant.update(image_ids: [])
        end.to change {
          store_products.map { |cp| cp.images.count }.flatten
        }.from([2, 2]).to [0, 0]
      end
    end
  end

  context '#updated_at' do
    let(:variant) { create :product_variant }
    let(:attribute_def) { create :attribute_def }

    before do
      Timecop.freeze
      @creation_date = variant.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)
    end

    after { Timecop.return }

    it 'adding a video change product updated at' do
      expect do
        variant.update!(video_attributes: { url: 'http://localhost/video' })
      end.to change {
        variant.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)
    end

    it 'adding/removing an image change variant updated at' do
      image_1 = create(:image, imageable: variant.product)
      image_2 = create(:image, imageable: variant.product)
      variant.images << image_1
      variant.update!(image_ids: [image_1.id])

      @creation_date = variant.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)

      expect do
        variant.update!(image_ids: [image_1.id, image_2.id])
      end.to change {
        variant.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)

      @creation_date = variant.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)

      expect do
        variant.update!(image_ids: [image_1.id])
      end.to change {
        variant.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)
    end

    it 'adding/removing a tag change product updated at' do
      expect do
        variant.update!(tag_list: 'tag1,tag2,tag3')
      end.to change {
        variant.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)

      @creation_date = variant.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)

      expect do
        variant.update!(tag_list: 'tag1,tag2')
      end.to change {
        variant.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)
    end

    it 'adding/updating/removing an attribute change product updated at' do
      expect do
        variant.update!(attribute_values_attributes: [{ id: nil, attribute_def_id: attribute_def.id, value: 1 }])
      end.to change {
        variant.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)

      @creation_date = variant.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)

      expect do
        variant.update!(attribute_values_attributes: [{ id: variant.attribute_values.first.id, value: 2 }])
      end.to change {
        variant.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)

      @creation_date = variant.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)

      expect do
        variant.update!(attribute_values_attributes: [{ id: variant.attribute_values.first.id, _destroy: true }])
      end.to change {
        variant.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)
    end
  end

  context 'updating brand' do
    let(:store) { create :store }
    let(:brand_1) { create :brand }
    let(:brand_2) { create :brand }

    it 'change kiosk when product brand change' do
      kiosk_brand_1     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_1)
      kiosk_brand_2     = create(:kiosk, store: store, product_filter_criteria: :brand, product_filter_value: brand_2)

      variant = create :product_variant, brand: brand_1
      product_1 = create :store_product, store: store, brand: brand_1
      product_2 = create :store_product, store: store, brand: nil, product_variant: variant

      expect(kiosk_brand_1.kiosk_products.map(&:store_product)).to match_array [product_1, product_2]
      expect(kiosk_brand_2.kiosk_products.map(&:store_product)).to match_array []

      variant.update!(brand: brand_2)

      expect(kiosk_brand_1.kiosk_products.reload.map(&:store_product)).to match_array [product_1]
      expect(kiosk_brand_2.kiosk_products.reload.map(&:store_product)).to match_array [product_2]
    end
  end
end
