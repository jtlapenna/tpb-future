require 'rails_helper'

describe 'API V1 Catalogs' do
  include Api::V1::SerializationHelper::Stores
  include Api::V1::SerializationHelper::Rfids

  before do
    initialize_layout_positions
  end

  context '#tags' do
    let(:store) { create :store }
    let(:master_1) { create :product, tag_list: 'tag 8' }
    let(:master_2) { create :product, tag_list: 'tag 7' }
    let(:variant_1) { create :product_variant, tag_list: 'tag 9', product: master_1 }
    let(:variant_2) { create :product_variant, tag_list: 'tag 5', product: master_2 }
    let(:kiosk) { create :kiosk, store: store, tag_list: 'tag 1, tag 2, tag 4' }
    let(:store_product) { create :store_product, store: store, product_variant: variant_1, tag_list: 'tag 3' }

    before do
      store_product.touch
      create :kiosk_product, kiosk: kiosk, store_product: store_product
      create :kiosk_product, kiosk: kiosk, store_product:
        create(:store_product, store: store, product_variant: variant_2, tag_list: 'tag 6')
    end

    it 'return all catalogs and product tags' do
      get "/api/v1/#{kiosk.id}/tags", headers: auth_headers(kiosk.store)

      expect(json).to have_key('tags')
      expect(json['tags']).to match_array [
        'tag 1', 'tag 2', 'tag 3', 'tag 4', 'tag 5', 'tag 6', 'tag 7', 'tag 8', 'tag 9'
      ]
    end

    it 'return only catalog tags if featured flag' do
      get "/api/v1/#{kiosk.id}/tags", params: { featured_tags: true }, headers: auth_headers(kiosk.store)

      expect(json).to have_key('tags')
      expect(json['tags']).to match_array ['tag 1', 'tag 2', 'tag 4']
    end

    context 'when variant overrides master products tags' do
      before do
        variant_1.update!(override_tags: true)
      end

      it 'do not return master_1 product tags' do
        get "/api/v1/#{kiosk.id}/tags", headers: auth_headers(kiosk.store)

        expect(json).to have_key('tags')
        expect(json['tags']).to match_array [
          'tag 1', 'tag 2', 'tag 3', 'tag 4', 'tag 5', 'tag 6', 'tag 7', 'tag 9'
        ]
      end
    end

    context 'when store product overrides master and variant tags' do
      before do
        store_product.update!(override_tags: true)
      end

      it 'do not return master_1 and variant_1 tags' do
        get "/api/v1/#{kiosk.id}/tags", headers: auth_headers(kiosk.store)

        expect(json).to have_key('tags')
        expect(json['tags']).to match_array [
          'tag 1', 'tag 2', 'tag 3', 'tag 4', 'tag 5', 'tag 6', 'tag 7'
        ]
      end
    end
  end

  def kiosk_json(kiosk)
    includes = {
      layout: { only: %i[id template home_layout stand_side welcome_message rfid_disabled shopping_disabled screen_type], include: {
        welcome_asset: { only: [:id], include: { asset: { only: %i[id url] } } },
        navigation: { only: [:id] }
      } }
    }

    k_json = kiosk.as_json(only: [], include: includes).merge({
      sensor_method: kiosk.sensor_method,
      sensor_threshold: kiosk.sensor_threshold,
      notify_by_email: kiosk.store.notifications_enabled,
      notify_to_customer: kiosk.store.notifications_send_to_customer,
      api_type: kiosk.store.api_type
    }.stringify_keys)

    k_json['layout']['store_assets'] = kiosk.layout.kiosk_assets.map do |sa|
      { 'id' => sa.id, 'text' => sa.text, 'secondary_text' => sa.secondary_text, code: sa.code,
        'text_position' => sa.text_position.label, 'asset_position' => sa.asset_position.label,
        'section_position' => sa.section_position.label,
        'created_at' => sa.created_at.iso8601(3), 'updated_at' => sa.updated_at.iso8601(3),
        'dots' => sa.asset_elements.select { |pip| pip.element_type == 'dot' }.map do |ae|
          {
            'id' => ae.id, 'link' => ae.link, 'coord_x' => ae.coord_x, 'coord_y' => ae.coord_y,
            'created_at' => ae.created_at.iso8601(3), 'updated_at' => ae.updated_at.iso8601(3)
          }
        end,
        'pictures_in_pictures' => sa.asset_elements.select { |pip| pip.element_type == 'picture_in_picture' }.map do |ae|
          asset_json = !ae.asset ? nil : { 'id' => ae.asset.id, 'url' => ae.asset.url, 'created_at' => ae.asset.created_at.iso8601(3), 'updated_at' => ae.asset.updated_at.iso8601(3) }
          {
            'id' => ae.id, 'link' => ae.link, 'coord_x' => ae.coord_x, 'coord_y' => ae.coord_y,
            'created_at' => ae.created_at.iso8601(3), 'updated_at' => ae.updated_at.iso8601(3), 'asset' => asset_json
          }
        end,
        'asset' => { 'id' => sa.asset.id, 'url' => sa.asset.url, 'created_at' => sa.asset.created_at.iso8601(3), 'updated_at' => sa.asset.updated_at.iso8601(3) } }.stringify_keys
    end

    k_json['layout']['navigation']['items'] = kiosk.layout.navigation.items.map do |item|
      { 'id' => item.id, 'label' => item.label, 'order' => item.order, 'link' => item.link }.stringify_keys
    end

    if kiosk.layout.welcome_asset&.asset
      k_json['layout']['welcome_asset']['asset']['created_at'] = kiosk.layout.welcome_asset.asset.created_at.iso8601(3)
      k_json['layout']['welcome_asset']['asset']['updated_at'] = kiosk.layout.welcome_asset.asset.updated_at.iso8601(3)
    end

    if kiosk.layout.welcome_asset
      k_json['layout']['welcome_asset']['asset_position'] = kiosk.layout.welcome_asset.asset_position.label
      k_json['layout']['welcome_asset']['created_at'] = kiosk.layout.welcome_asset.created_at.iso8601(3)
      k_json['layout']['welcome_asset']['updated_at'] = kiosk.layout.welcome_asset.updated_at.iso8601(3)
    else
      k_json['layout']['welcome_asset'] = nil
    end

    k_json['layout']['created_at'] = kiosk.layout.created_at.iso8601(3)
    k_json['layout']['updated_at'] = kiosk.layout.updated_at.iso8601(3)

    k_json
  end

  context '#settings' do
    let(:kiosk) { create :kiosk, store: store }
    let(:store) { create :store, logo: build(:asset) }
    let!(:kiosk_layout) { kiosk.layout }
    let!(:welcome_asset) { create :welcome_asset, asset_position_id: LayoutPosition.first.id, kiosk_layout: kiosk_layout }
    let!(:kiosk_asset) do
      create :kiosk_asset,
             text_position_id: LayoutPosition.first.id,
             asset_position_id: LayoutPosition.first.id,
             section_position_id: LayoutPosition.last.id,
             kiosk_layout: kiosk_layout
    end
    let!(:dot_asset) { create :asset_element, link: 'dot link', kiosk_asset: kiosk_asset }
    let!(:pip_asset) { create :asset_element, link: 'pip link', kiosk_asset: kiosk_asset }
    let!(:asset1) { create :asset, url: 'theurlimage.com', source: pip_asset }
    let!(:asset2) { create :asset, url: 'urlimage.com', source: kiosk_asset }
    let!(:asset3) { create :asset, url: 'welcomeurlimage.com', source: welcome_asset }
    let(:kiosk) { create :kiosk, store: store, sensor_method: 'rfid', sensor_threshold: 123 }

    it 'return store with config layout' do
      get "/api/v1/#{kiosk.id}/settings", headers: auth_headers(store)

      kiosk_json = kiosk_json(kiosk)

      expect(json).to have_key('catalog')
      expect(json['catalog']).to eq kiosk_json

      expect(json).to have_key('store')
      expect(json['store']).to have_key('layout')

      expect(json['store']).to eq store_json(store).merge('layout' => kiosk_json['layout'])
    end

    context 'layout Navigation with items' do
      let!(:navigation) { kiosk.layout.navigation }

      before do
        navigation.items.create label: 'third in order', title: 'third title', description: 'third description', order: 7
        navigation.items.create label: 'first in order', order: 3
        navigation.items.create label: 'second in order', order: 5

        get "/api/v1/#{kiosk.id}/settings", headers: auth_headers(store)
      end

      it 'items ordered by column order' do
        expect(json['catalog']['layout']['navigation']['items'].map { |item| item['id'] }).to eq navigation.items.sort_by(&:order).map(&:id)
        expect(json['catalog']['layout']['navigation']['items'].last).to include('title' => 'third title', 'description' => 'third description', 'order' => 7)
      end
    end
  end

  context '#rfids' do
    let(:kiosk) { create :kiosk }
    let(:kiosk_product_1) { create :kiosk_product, kiosk: kiosk }
    let(:kiosk_product_2) { create :kiosk_product, kiosk: kiosk }
    let(:category) { create :store_category, store: kiosk.store }
    let(:brand) { create :brand }
    let!(:rfid_1) { create :rfid_product, rfid: '1234', rfid_entity: kiosk_product_1 }
    let!(:rfid_2) { create :rfid_product, rfid: '123', rfid_entity: kiosk_product_2 }
    let!(:rfid_3) { create :rfid_product, rfid: '12345', rfid_entity: category, kiosk: kiosk }
    let!(:rfid_4) { create :rfid_product, rfid: '123456', rfid_entity: brand, kiosk: kiosk }

    it 'return all catalogs and product tags' do
      get "/api/v1/#{kiosk.id}/rfids", headers: auth_headers(kiosk.store)

      expect(json).to have_key('rfids')
      expect(json['rfids'].count).to eq 4
      expect(json['rfids']).to eq [
          rfid_json(rfid_1),
          rfid_json(rfid_2),
          rfid_json(rfid_3),
          rfid_json(rfid_4)
      ]
    end
  end
end
