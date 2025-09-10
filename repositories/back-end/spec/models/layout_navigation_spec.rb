require 'rails_helper'

describe LayoutNavigation do
  let(:layout_navigation) { build_stubbed :layout_navigation }

  it 'is valid' do
    expect(layout_navigation).to be_valid
  end

  it 'is not valid without layout' do
    layout_navigation.kiosk_layout = nil
    expect(layout_navigation).not_to be_valid
  end
end
