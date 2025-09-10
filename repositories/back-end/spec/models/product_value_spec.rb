require 'rails_helper'

describe ProductValue do
  let(:value) { build_stubbed :product_value }

  it 'is valid' do
    expect(value).to be_valid
  end

  it 'is not valid without valuable' do
    value.valuable = nil
    expect(value).not_to be_valid
    expect(value.errors[:valuable]).to eq ['must exist']
  end

  it 'is not valid with a negative value' do
    value.value = -1
    expect(value).not_to be_valid
    expect(value.errors[:value]).to eq ['must be greater than or equal to 0']
  end

  it 'value has two decimals' do
    value.value = 20.2350
    expect(value.value).to eq 20.24
  end
end
