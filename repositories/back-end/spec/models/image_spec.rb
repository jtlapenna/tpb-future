require 'rails_helper'

describe Image do
  let(:image) { build_stubbed :image }

  it 'is valid' do
    expect(image).to be_valid
  end

  it 'is not valid without url' do
    image.url = nil
    expect(image).not_to be_valid
    expect(image.errors[:url]).to eq ["can't be blank"]
  end
end
