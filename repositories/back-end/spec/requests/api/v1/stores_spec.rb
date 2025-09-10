require 'rails_helper'

describe 'API V1 StoreLayouts ' do
  include Api::V1::SerializationHelper::Stores

  before do
    initialize_layout_positions
  end

  context '#show' do
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
    let(:params) { { id: store.id } }

    it 'return store with config layout' do
      get show_api_v1_stores_path, headers: auth_headers(store)

      expect(json).to have_key('store')
      expect(json['store']).to eq(store_json(store))
    end

    context 'with settings' do
      let(:store) { create :store, logo: build(:asset), settings: settings }
      let(:settings) { create :store_setting, data: settings_attributes }
      let(:settings_attributes) do
        {
          admin_email: 'admin_email (string)',
          printer_location: 'printer_location (string)',
          pos_location: 'pos_location (string)',
          main_color: 'main_color (hexadecimal)',
          secondary_color: 'secondary_color ( hexadecimal) ',
          featured_products_on_top_for_brands_page: 'featured... for brands (bool)',
          featured_products_on_top_for_effects_and_uses_page: 'featured... for effects and uses (bool)',
          featured_products_on_top_for_products_page: 'featured... for productos (bool)',
          idle_delay: 'idle_delay (seconds)',
          restart_delay: 'restart_delay (seconds)',
          service_worker_log: 'service_worker_log (bool)',
          default_product_description: 'default_product_description (text)',
          heap_id: 'heap_id( string )',
          dispensary_license_number: '123',
          disable_tax_message: 'disable_tax_message (bool)'
        }
      end

      it 'return store settings' do
        get show_api_v1_stores_path, headers: auth_headers(store)

        expect(json['store']['settings']).to eq settings_attributes.merge('background_media' => nil).stringify_keys
      end
    end
  end
end
