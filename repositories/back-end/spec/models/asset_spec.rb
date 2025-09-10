require 'rails_helper'

describe Asset do
  let(:asset) { build_stubbed :asset }

  it 'is valid' do
    expect(asset).to be_valid
  end

  it 'is not valid without url' do
    asset.url = nil
    expect(asset).not_to be_valid
    expect(asset.errors[:url]).to eq ["can't be blank"]
  end
end
