require 'rails_helper'

describe ProductLayoutValue do
  let(:value) { build :product_layout_value }

  shared_examples 'product layout value' do
    it 'is valid' do
      expect(value).to be_valid
    end

    it 'is not valid without kiosk product' do
      value.kiosk_product = nil

      expect(value).not_to be_valid
    end

    it 'is not valid without layout element' do
      value.product_layout_element = nil

      expect(value).not_to be_valid
    end
  end

  context 'medium' do
    let(:value) { build :product_layout_medium_value }

    include_examples 'product layout value'

    it 'is not valid without asset' do
      value.asset = nil

      expect(value).not_to be_valid
    end
  end

  context 'dot' do
    let(:value) { build :product_layout_dot_value }

    include_examples 'product layout value'

    it 'is not valid without link' do
      value.link = nil

      expect(value).not_to be_valid
    end
  end

  context 'text' do
    let(:value) { build :product_layout_text_value }

    include_examples 'product layout value'

    it 'is not valid without content' do
      value.content = nil

      expect(value).not_to be_valid
    end
  end
end
