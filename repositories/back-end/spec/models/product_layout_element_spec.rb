require 'rails_helper'

describe ProductLayoutElement do
  let(:layout) { build :product_layout_element }

  it 'is valid' do
    expect(layout).to be_valid
  end

  it 'is not valid without element_type' do
    layout.element_type = nil

    expect(layout).not_to be_valid
  end

  it 'is not valid without coord_x' do
    layout.coord_x = nil

    expect(layout).not_to be_valid
  end

  it 'is not valid without coord_y' do
    layout.coord_y = nil

    expect(layout).not_to be_valid
  end

  it 'is not valid without source' do
    layout.source = nil

    expect(layout).not_to be_valid
  end
end
