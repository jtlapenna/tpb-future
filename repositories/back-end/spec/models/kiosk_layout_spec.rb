require 'rails_helper'

describe KioskLayout do
  let(:kiosk_layout) { build_stubbed :kiosk_layout }

  it 'is valid' do
    expect(kiosk_layout).to be_valid
  end

  it 'is not valid without kiosk' do
    kiosk_layout.kiosk = nil
    expect(kiosk_layout).not_to be_valid
  end

  it 'is valid without product layout' do
    kiosk_layout.product_layout = nil

    expect(kiosk_layout).to be_valid
  end

  it 'when create, default template shopping' do
    kiosk_layout = create :kiosk_layout
    expect(kiosk_layout.template).to eq 'shopping'
  end

  it 'do not everride template if provided' do
    kiosk_layout = create :kiosk_layout, template: :brand

    expect(kiosk_layout.template).to eq 'brand'
  end

  it 'on create, generate navigation' do
    kiosk_layout = create :kiosk_layout
    expect(kiosk_layout.navigation).to be_present
  end

  context 'product layout change' do
    let(:kiosk_layout) { create :kiosk_layout }
    let(:kiosk_product) { create :kiosk_product, kiosk: kiosk_layout.kiosk }
    let(:value) { create :product_layout_medium_value, kiosk_product: kiosk_product }
    let(:product_layout) { value.product_layout_element.source.product_layout }
    let(:common_element) { create :product_layout_medium, source: product_layout }

    it 'should destroy values from previous layout' do
      create :product_layout_medium_value, product_layout_element: common_element, kiosk_product: kiosk_product
      kiosk_layout.update!(product_layout: product_layout)

      expect { kiosk_layout.update!(product_layout: nil) }.to change { ProductLayoutValue.count }.by(-2)
    end

    it "should not touch values when layout doesn't change" do
      create :product_layout_medium_value, product_layout_element: common_element, kiosk_product: kiosk_product
      kiosk_layout.update!(product_layout: product_layout)

      expect { kiosk_layout.update!(welcome_message: "#{kiosk_layout.welcome_message}1") }.not_to change { ProductLayoutValue.count }
    end
  end
end
