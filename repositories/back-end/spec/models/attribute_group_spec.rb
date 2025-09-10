require 'rails_helper'

describe AttributeGroup do
  let(:group) { build_stubbed :attribute_group }

  it 'is valid' do
    expect(group).to be_valid
  end

  it 'is not valid without name' do
    group.name = nil
    expect(group).not_to be_valid
    expect(group.errors[:name]).to eq ["can't be blank"]
  end

  it 'is short text' do
    expect(group).to be_short_text
  end

  describe 'name' do
    let!(:group) { create :attribute_group }

    it 'should be unique' do
      another_group = build :attribute_group, name: group.name

      expect(another_group).not_to be_valid
      expect(another_group.errors[:name]).to eq ['has already been taken']
    end
  end

  context 'destroy' do
    let(:group) { create :attribute_group }
    let(:product) { create :product }
    let(:variant) { create :product_variant, product: product }
    let(:c_product) { create :store_product, product_variant: variant }

    before do
      defs = create_list :attribute_def, 3, attribute_group: group
      product.attribute_values << build(:attribute_value, attribute_def: defs[0], value: 'ABC')
      variant.attribute_values << build(:attribute_value, attribute_def: defs[0], value: '123')
      c_product.attribute_values << build(:attribute_value, attribute_def: defs[0], value: '321')
    end

    it 'destroy group attributes' do
      expect do
        group.destroy
      end.to change {
        AttributeDef.count
      }.from(3).to 0
    end

    it 'destroy product attributes' do
      expect do
        group.destroy
      end.to change {
        product.attribute_values.count
      }.from(1).to 0
    end

    it 'destroy variant attributes' do
      expect do
        group.destroy
      end.to change {
        variant.attribute_values.count
      }.from(1).to 0
    end

    it 'destroy variant attributes' do
      expect do
        group.destroy
      end.to change {
        c_product.attribute_values.count
      }.from(1).to 0
    end
  end
end
