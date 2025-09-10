require 'rails_helper'

describe ProductLayout do
  let(:layout) { build :product_layout }

  it 'is valid' do
    expect(layout).to be_valid
  end

  it 'is not valid without name' do
    layout.name = nil

    expect(layout).not_to be_valid
  end

  it 'is not valid when name already exists' do
    other = create :product_layout

    layout.name = other.name.upcase

    expect(layout).not_to be_valid
  end

  context '#destroy' do
    it 'should destroy tab, elements & values' do
      value = create :product_layout_medium_value

      layout = value.product_layout_element.source.product_layout

      create :product_layout_text, source: layout

      expect(ProductLayout.count).to eq 1
      expect(ProductLayoutTab.count).to eq 1
      expect(ProductLayoutElement.count).to eq 2
      expect(ProductLayoutValue.count).to eq 1

      layout.destroy

      expect(ProductLayout.count).to eq 0
      expect(ProductLayoutTab.count).to eq 0
      expect(ProductLayoutElement.count).to eq 0
      expect(ProductLayoutValue.count).to eq 0
    end

    it 'touch kiosk product' do
      value = create :product_layout_medium_value

      layout = value.product_layout_element.source.product_layout
      product = value.kiosk_product

      expect { layout.destroy }.to change { product.reload.updated_at }
    end

    it 'nullify kiosk layout reference' do
      value = create :product_layout_medium_value

      layout = value.product_layout_element.source.product_layout
      kiosk_layout = value.kiosk_product.kiosk.layout
      kiosk_layout.update!(product_layout: layout)

      expect { layout.destroy }.to change { kiosk_layout.reload.product_layout }.from(layout).to(nil)
    end
  end
end
