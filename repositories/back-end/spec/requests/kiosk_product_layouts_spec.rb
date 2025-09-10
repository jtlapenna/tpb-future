require 'rails_helper'

describe 'Kiosk Product Layouts API' do
  let(:user) { create :user }
  let(:store) { create :store }
  let(:kiosk) { create :kiosk, store: store }

  context '#show' do
    let(:params) {}
    let(:store_product) { create :store_product, store: store }
    let(:product) { create :kiosk_product, kiosk: kiosk, store_product: store_product }

    it 'return layout' do
      medium = create :product_layout_medium
      dot = create :product_layout_dot, source: medium.source
      text = create :product_layout_text, source: medium.source

      create :product_layout_medium_value, product_layout_element: medium, kiosk_product: product
      create :product_layout_dot_value, product_layout_element: dot, kiosk_product: product
      create :product_layout_text_value, product_layout_element: text, kiosk_product: product

      get kiosk_kiosk_product_layout_path(kiosk.id, product.id), params: params, headers: auth_headers(user)

      expect(json).to have_key('layout')
      expect(json['layout']).to eq kiosk_product_layout_json(product)
    end
  end

  context '#update' do
    let(:product) { create :kiosk_product, kiosk: kiosk, stylesheet: 'some css' }

    let(:medium) { create :product_layout_medium }
    let(:medium_2) { create :product_layout_medium }
    let(:dot) { create :product_layout_dot, source: medium.source }
    let(:text) { create :product_layout_text, source: medium.source }

    let(:medium_value) { create :product_layout_medium_value, product_layout_element: medium, kiosk_product: product }
    let(:dot_value) { create :product_layout_dot_value, product_layout_element: dot, kiosk_product: product, link: 'http://some.link.com' }

    let(:params) do
      {
        kiosk_product_layout: {
          stylesheet: 'new some css',
          values: [
            { id: medium_value.id, _destroy: true },
            { id: dot_value.id, link: 'http://other.link.com' },
            { id: nil, product_layout_element_id: text.id, content: 'some new content' },
            { id: nil, product_layout_element_id: medium_2.id, asset_attributes: { url: 'https://assets/file.png' } }
          ]
        }
      }
    end

    it 'update layout' do
      put kiosk_kiosk_product_layout_path(kiosk, product), params: params, headers: auth_headers(user)

      expect(product.reload.stylesheet).to eq 'new some css'
      expect(product.product_layout_values.count).to eq 3
      expect(product.product_layout_values.map(&:product_layout_element_id)).to match_array [dot.id, text.id, medium_2.id]
      expect(product.product_layout_values.map(&:content)).to match_array ['some new content', nil, nil]
      expect(product.product_layout_values.map(&:link)).to match_array ['http://other.link.com', nil, nil]
      expect(product.product_layout_values.map { |v| v.asset&.url }).to match_array ['https://assets/file.png', nil, nil]
    end

    it 'return updated product' do
      put kiosk_kiosk_product_layout_path(kiosk, product), params: params, headers: auth_headers(user)

      expect(json).to have_key('layout')
      expect(json['layout']).to eq kiosk_product_layout_json(product.reload)
    end
  end

  def kiosk_product_layout_json(product)
    {
      stylesheet: product.stylesheet,
      values: product.product_layout_values.map { |value| kiosk_product_layout_value_json(value) }
    }.as_json
  end

  def kiosk_product_layout_value_json(value)
    value.as_json(only: %i[id content link product_layout_element_id]).tap do |json|
      json['asset'] = nil
      json['asset'] = value.asset.as_json(only: %i[id url]) if value.asset
    end
  end
end
