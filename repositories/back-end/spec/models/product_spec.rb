require 'rails_helper'

describe Product do
  let(:product) { build_stubbed :product }

  it 'is valid' do
    expect(product).to be_valid
  end

  it 'is not valid without name' do
    product.name = nil
    expect(product).not_to be_valid
  end

  context '#updated_at' do
    let(:product) { create :product }
    let(:attribute_def) { create :attribute_def }

    before do
      Timecop.freeze
      @creation_date = product.reload.updated_at.iso8601(1)
      # add an image
      create(:image, imageable: product)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)
    end

    after { Timecop.return }

    it 'adding a video change product updated at' do
      expect do
        product.update!(video_attributes: { url: 'http://localhost/video' })
      end.to change {
        product.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)
    end

    it 'adding/removing an image change product updated at' do
      expect do
        product.update!(images_attributes: [{ id: nil, url: 'http://localhost/image' }])
      end.to change {
        product.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)

      @creation_date = product.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)

      expect do
        product.update!(images_attributes: [{ id: product.images.first.id, _destroy: true }])
      end.to change {
        product.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)
    end

    it 'adding/removing a tag change product updated at' do
      expect do
        product.update!(tag_list: 'tag1,tag2,tag3')
      end.to change {
        product.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)

      @creation_date = product.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)

      expect do
        product.update!(tag_list: 'tag1,tag2')
      end.to change {
        product.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)
    end

    it 'adding/updating/removing an attribute change product updated at' do
      expect do
        product.update!(attribute_values_attributes: [{ id: nil, attribute_def_id: attribute_def.id, value: 1 }])
      end.to change {
        product.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)

      @creation_date = product.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)

      expect do
        product.update!(attribute_values_attributes: [{ id: product.attribute_values.first.id, value: 2 }])
      end.to change {
        product.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)

      @creation_date = product.reload.updated_at.iso8601(1)
      Timecop.travel 5.minutes.from_now
      Timecop.freeze
      @updated_date = Time.current.iso8601(1)

      expect do
        product.update!(attribute_values_attributes: [{ id: product.attribute_values.first.id, _destroy: true }])
      end.to change {
        product.reload.updated_at.iso8601(1)
      }.from(@creation_date).to(@updated_date)
    end
  end
end
