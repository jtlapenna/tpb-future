require 'rails_helper'

describe AssetElement do
  let(:asset_element) { build_stubbed :asset_element }

  it 'is valid' do
    expect(asset_element).to be_valid
  end

  it 'is not valid without store_asset' do
    asset_element.kiosk_asset = nil
    expect(asset_element).not_to be_valid
  end
end
