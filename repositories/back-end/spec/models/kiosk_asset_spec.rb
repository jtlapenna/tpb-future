require 'rails_helper'

describe KioskAsset do
  let(:kiosk_asset) { build_stubbed :kiosk_asset }

  it 'is valid' do
    expect(kiosk_asset).to be_valid
  end

  it 'is not valid without store_layout' do
    kiosk_asset.kiosk_layout = nil
    expect(kiosk_asset).not_to be_valid
  end
end
