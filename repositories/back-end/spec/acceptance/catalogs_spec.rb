require 'acceptance_helper'

resource 'Catalogs', type: :request do
  let(:store) do
    create :treez_store,
           notifications_enabled: true,
           notifications_send_to_customer: false,
           notifications_recipients: ['admin@admin.org'],
           notifications_title: 'title',
           notifications_intro: 'intro',
           logo: build(:asset)
  end
  let(:kiosk) { create :kiosk, store: store, tag_list: 'tag 1, tag 2, tag 4' }
  let(:api_key) { auth_token(store) }

  explanation 'Catalogs resource'

  authentication :apiKey, :api_key, description: 'Private key for API access', name: 'Authorization'
  header 'Content-Type', 'application/json'

  before do
    initialize_layout_positions
  end

  get '/api/v1/:catalog_id/settings' do
    let(:catalog_id) { kiosk.id }
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

    route_summary 'Get catalog details'

    context '200' do
      example_request 'get catalog' do
        expect(status).to eq 200

        expect(json).to have_key 'catalog'
      end
    end
  end

  get '/api/v1/:catalog_id/tags' do
    let(:catalog_id) { kiosk.id }

    route_summary 'Get catalog tags'

    context '200' do
      example_request 'get catalog tags' do
        expect(status).to eq 200

        expect(json).to have_key 'tags'
        expect(json['tags'].count).to eq 3
      end
    end
  end
end
