require 'rails_helper'

describe ProductLayoutTab do
  let(:layout) { build :product_layout_tab }

  it 'is valid' do
    expect(layout).to be_valid
  end

  it 'is not valid without name' do
    layout.name = nil

    expect(layout).not_to be_valid
  end

  it 'is not valid without order' do
    layout.order = nil

    expect(layout).not_to be_valid
  end

  it 'is not valid without layout' do
    layout.product_layout = nil

    expect(layout).not_to be_valid
  end
end
