require 'rails_helper'

describe AttributeValue do
  let(:attribute_value) { build_stubbed :attribute_value }

  it 'is valid' do
    expect(attribute_value).to be_valid
  end

  it 'is not valid without value' do
    attribute_value.value = nil
    expect(attribute_value).not_to be_valid
    expect(attribute_value.errors[:value]).to eq ["can't be blank"]
  end

  it 'is not valid without target' do
    attribute_value.target = nil
    expect(attribute_value).not_to be_valid
    expect(attribute_value.errors[:target]).to eq ['must exist']
  end
end
