require 'rails_helper'

describe AttributeDef do
  let(:attribute_def) { build_stubbed :attribute_def }

  it 'is valid' do
    expect(attribute_def).to be_valid
  end

  it 'is not valid without name' do
    attribute_def.name = nil
    expect(attribute_def).not_to be_valid
    expect(attribute_def.errors[:name]).to eq ["can't be blank"]
  end

  it 'is valid without group' do
    attribute_def.attribute_group = nil
    expect(attribute_def).to be_valid
  end

  it 'is not restricted' do
    expect(attribute_def).not_to be_restricted
  end

  context 'restricted attributes' do
    let(:attribute_def) { build_stubbed :attribute_def, restricted: true, values: ['value 1', 'value 2'] }

    it 'is valid' do
      expect(attribute_def).to be_valid
    end

    it 'is restricted' do
      expect(attribute_def).to be_restricted
    end

    it 'available values are required' do
      attribute_def.values = nil
      expect(attribute_def).not_to be_valid
      expect(attribute_def.errors[:values]).to eq ["can't be blank"]

      attribute_def.values = []
      expect(attribute_def).not_to be_valid
      expect(attribute_def.errors[:values]).to eq ["can't be blank"]
    end
  end

  context 'changing restricted condition' do
    let(:attribute_def) { create :attribute_def, restricted: true, values: ['value 1'] }

    it 'clean values when it is not restricted' do
      expect do
        attribute_def.update(restricted: false)
      end.to change {
        attribute_def.values
      }.from(['value 1']).to []
    end
  end

  context 'destroy' do
    let(:attribute_def) { create :attribute_def }

    before do
      attribute_def.touch
      prod = create :product
      variant = create :product_variant, product: prod
      create :attribute_value, target: prod, attribute_def: attribute_def
      create :attribute_value, target: variant, attribute_def: attribute_def
      create :attribute_value, target: variant, attribute_def: create(:attribute_def)
    end

    it 'destroy attributes values' do
      expect do
        attribute_def.destroy
      end.to change {
        AttributeValue.count
      }.from(3).to(1)
    end
  end
end
