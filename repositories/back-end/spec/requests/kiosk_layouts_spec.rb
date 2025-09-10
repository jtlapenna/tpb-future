require 'rails_helper'

describe 'KioskLayouts API' do
  let(:user) { create :user }

  def kiosk_layout_json(kiosk_layout)
    includes = {
      welcome_asset: { only: %i[id asset_position_id], include: { asset: { only: %i[id url] } } },
      kiosk: { only: %i[id name] },
      navigation: { only: [:id] }
    }
    s_json = kiosk_layout.as_json(only: %i[
                                    id template home_layout product_layout_id stand_side welcome_message rfid_disabled shopping_disabled screen_type
                                  ], include: includes)

    s_json['navigation']['items'] = kiosk_layout.navigation.items.map do |item|
      { 'id' => item.id, 'label' => item.label, 'title' => item.title, 'description' => item.description, 'order' => item.order, 'link' => item.link, asset: item.asset.as_json(only: %i[id url]) }.stringify_keys
    end

    s_json['kiosk_assets'] = kiosk_layout.kiosk_assets.map do |sa|
      { 'id' => sa.id, 'text' => sa.text, 'secondary_text' => sa.secondary_text, code: sa.code,
        'text_position_id' => sa.text_position_id, 'asset_position_id' => sa.asset_position_id,
        'section_position_id' => sa.section_position_id,
        'asset_elements' => sa.asset_elements.map do |ae|
          !ae.asset ? nil : asset_json = { 'id' => ae.asset.id, 'url' => ae.asset.url }
          {
            'id' => ae.id, 'link' => ae.link, 'coord_x' => ae.coord_x, 'coord_y' => ae.coord_y,
            'element_type' => ae.element_type, 'asset' => asset_json
          }
        end,
        'asset' => { 'id' => sa.asset.id, 'url' => sa.asset.url } }.stringify_keys
    end

    s_json['welcome_asset'] = nil unless kiosk_layout.welcome_asset

    s_json
  end

  before do
    initialize_layout_positions
  end

  context '#update' do
    let(:kiosk) { create :kiosk }
    let(:kiosk_layout) { kiosk.layout }
    let(:params) { { kiosk_layout: { template: 'shopping', home_layout: 'swipe', stand_side: 'right', screen_type: 'big_screen', product_layout_id: product_layout.id } } }
    let(:missing_name_params) { { kiosk_layout: { template: '' } } }
    let(:product_layout) { create :product_layout }

    it 'update kiosk_layout' do
      expect(kiosk_layout.product_layout).not_to be

      put kiosk_layout_path(kiosk, kiosk_layout), params: params, headers: auth_headers(user)

      expect(kiosk_layout.reload.template).to eq 'shopping'
      expect(kiosk_layout.home_layout).to eq 'swipe'
      expect(kiosk_layout.stand_side).to eq 'right'
      expect(kiosk_layout.product_layout).to eq product_layout
    end

    it 'return updated store_layout' do
      put kiosk_layout_path(kiosk, kiosk_layout), params: params, headers: auth_headers(user)

      expect(json).to have_key('kiosk_layout')
      expect(json['kiosk_layout']).to eq kiosk_layout_json(kiosk_layout.reload)
    end

    it 'return errors' do
      put kiosk_layout_path(kiosk, kiosk_layout), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('template')
      expect(json['errors']).to eq('template' => ["can't be blank"])
    end

    context 'with all attributes nested' do
      let(:params) do
        {
          kiosk_layout: {
            id: kiosk_layout.id,
            template: 'shopping',
            home_layout: 'swipe',
            stand_side: 'right',
            screen_type: 'big_screen',
            welcome_asset_attributes: {
              id: nil, asset_position_id: LayoutPosition.first.id, _destroy: false,
              asset_attributes: { url: 'https://peak-beyond-test.s3.amazonaws.com/products/35189223-29ed-4c20-8279-87c5354d47b0/file.png', _destroy: false }
            },
            kiosk_assets_attributes: [{
              id: nil, text: 'First asset', secondary_text: 'and alone asset', asset_position_id: LayoutPosition.first.id, code: 'a code',
              text_position_id: LayoutPosition.last.id, section_position_id: LayoutPosition.first.id, _destroy: false,
              asset_elements_attributes: [
                {
                  id: nil, coord_x: 'First', coord_y: 'pip', element_type: 'picture_in_picture',
                  link: 'alone', _destroy: false,
                  asset_attributes: { url: 'https://peak-beyond-test.s3.amazonaws.com/products/c886871d-3415-473b-acf1-3b0baf2a008d/file.png', _destroy: false }
                },
                { id: nil, coord_x: 'dot', coord_y: 'alone', element_type: 'dot', link: 'First', _destroy: false }
              ],
              asset_attributes: { url: 'https://peak-beyond-test.s3.amazonaws.com/products/2d64ddd2-d043-43ea-9bcc-626b13e7cca4/file.png', _destroy: false }
            }],
            navigation_attributes: {
              id: kiosk_layout.navigation.id,
              items_attributes: [
                {
                  id: nil, label: 'First item', link: 'www.link.com.ar', order: '1', _destroy: false,
                  title: 'First item title', description: 'First item description',
                  asset_attributes: { url: 'https://peak-beyond-test.s3.amazonaws.com/products/c886871d-3415-473b-acf1-3b0baf2a008d/file.png', _destroy: false }
                }
              ],
              asset_attributes: { url: 'https://peak-beyond-test.s3.amazonaws.com/products/2d64ddd2-d043-43ea-9bcc-626b13e7cca4/file.png', _destroy: false }
            }
          },
          kiosk_id: kiosk.id, id: kiosk_layout.id
        }
      end

      it 'update attributes stores_layout' do
        put kiosk_layout_path(kiosk, kiosk_layout), params: params, headers: auth_headers(user)

        expect(kiosk_layout.reload).to be
        expect(kiosk_layout.kiosk.id).to eq kiosk.id
        expect(kiosk_layout.navigation).to be_present
        expect(kiosk_layout.kiosk_assets.count).to eq 1
        expect(kiosk_layout.screen_type).to eq 'big_screen'
        expect(kiosk_layout.welcome_asset.asset_position_id).to eq LayoutPosition.first.id
        expect(kiosk_layout.welcome_asset.asset.url).to eq 'https://peak-beyond-test.s3.amazonaws.com/products/35189223-29ed-4c20-8279-87c5354d47b0/file.png'
        expect(kiosk_layout.kiosk_assets[0].text).to eq 'First asset'
        expect(kiosk_layout.kiosk_assets[0].secondary_text).to eq 'and alone asset'
        expect(kiosk_layout.kiosk_assets[0].code).to eq 'a code'
        expect(kiosk_layout.kiosk_assets[0].text_position.id).to eq LayoutPosition.last.id
        expect(kiosk_layout.kiosk_assets[0].asset_position.id).to eq LayoutPosition.first.id
        expect(kiosk_layout.kiosk_assets[0].section_position.id).to eq LayoutPosition.first.id
        element_pip = kiosk_layout.kiosk_assets[0].asset_elements.detect { |ae| ae.element_type == 'picture_in_picture' }
        expect(element_pip.link).to eq 'alone'
        expect(element_pip.coord_x).to eq 'First'
        expect(element_pip.coord_y).to eq 'pip'
        expect(element_pip.asset.url).to eq 'https://peak-beyond-test.s3.amazonaws.com/products/c886871d-3415-473b-acf1-3b0baf2a008d/file.png'
        element_dot = kiosk_layout.kiosk_assets[0].asset_elements.detect { |ae| ae.element_type == 'dot' }
        expect(element_dot.link).to eq 'First'
        expect(element_dot.coord_x).to eq 'dot'
        expect(element_dot.coord_y).to eq 'alone'
        expect(kiosk_layout.kiosk_assets[0].asset.url).to eq 'https://peak-beyond-test.s3.amazonaws.com/products/2d64ddd2-d043-43ea-9bcc-626b13e7cca4/file.png'
        expect(kiosk_layout.navigation.items[0].asset.url).to eq 'https://peak-beyond-test.s3.amazonaws.com/products/c886871d-3415-473b-acf1-3b0baf2a008d/file.png'
        expect(kiosk_layout.navigation.items[0].label).to eq 'First item'
        expect(kiosk_layout.navigation.items[0].title).to eq 'First item title'
        expect(kiosk_layout.navigation.items[0].description).to eq 'First item description'

        expect(json['kiosk_layout']).to eq kiosk_layout_json(kiosk_layout.reload)
      end
    end
  end

  context '#show' do
    let(:kiosk) { create :kiosk, store: store }
    let(:store) { create :store }
    let!(:kiosk_layout) { kiosk.layout }
    let!(:welcome_asset) { create :welcome_asset, kiosk_layout: kiosk_layout }
    let!(:kiosk_asset) do
      create :kiosk_asset,
             text_position_id: LayoutPosition.first.id,
             asset_position_id: LayoutPosition.first.id,
             section_position_id: LayoutPosition.first.id,
             kiosk_layout: kiosk_layout
    end
    let!(:dot_asset) { create :asset_element, link: 'dot link', kiosk_asset: kiosk_asset }
    let!(:pip_asset) { create :asset_element, link: 'pip link', kiosk_asset: kiosk_asset }
    let!(:asset1) { create :asset, url: 'theurlimage.com', source: pip_asset }
    let!(:asset2) { create :asset, url: 'urlimage.com', source: kiosk_asset }
    let!(:asset3) { create :asset, url: 'welcomeurlimage.com', source: welcome_asset }
    let(:params) { { id: kiosk_layout.id } }

    it 'return kiosk_layout' do
      get kiosk_layout_path(kiosk, kiosk_layout), params: params, headers: auth_headers(user)

      expect(json).to have_key('kiosk_layout')
      expect(json['kiosk_layout']).to eq(kiosk_layout_json(kiosk_layout))
    end
  end
end
