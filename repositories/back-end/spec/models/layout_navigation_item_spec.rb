require 'rails_helper'

describe LayoutNavigationItem do
  let(:layout_navigation_item) { build :layout_navigation_item }

  it 'is valid' do
    expect(layout_navigation_item).to be_valid
  end

  it 'is not valid without layout_navigation' do
    layout_navigation_item.layout_navigation = nil
    expect(layout_navigation_item).not_to be_valid
  end
end
