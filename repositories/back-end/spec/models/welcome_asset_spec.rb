require 'rails_helper'

describe WelcomeAsset do
  let(:welcome_asset) { build :welcome_asset }

  it 'is valid' do
    expect(welcome_asset).to be_valid
  end

  it 'is not valid without store_layout' do
    welcome_asset.kiosk_layout = nil
    expect(welcome_asset).not_to be_valid
  end
end
