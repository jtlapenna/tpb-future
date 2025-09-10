require 'rails_helper'

describe CloneKioskOperation do
  subject(:operation) { described_class.new.call(kiosk) }

  let(:kiosk) { create :kiosk, product_filter_criteria: :category }
  let(:store) { kiosk.store }
  let(:cloned_kiosk) { Kiosk.last }

  before do
    stub_request :any, /s3\.sa-east-1\.amazonaws.com/
    # Setup kiosk with some products
    prod = create :store_product, store_category: store.store_categories.first
    kiosk.product_filter_value_type = 'StoreCategory'
    kiosk.product_filter_value_id = prod.store_category_id
    # welcome_asset
    create :welcome_asset, kiosk_layout: kiosk.layout
    create :asset, source: kiosk.layout.welcome_asset, url: 'https://test-images.s3.sa-east-1.amazonaws.com/stores/xxx/yyy.jpeg'
    kiosk.layout.navigation.items << create(:layout_navigation_item)
    create_list :kiosk_asset, 2, kiosk_layout: kiosk.layout
    # one of both has an associated asset.
    create :asset, source: kiosk.layout.kiosk_assets.first, url: 'https://test-images.s3.sa-east-1.amazonaws.com/stores/xxx/zzz.png'
    kiosk.save!
  end

  it 'return success' do
    expect(operation).to be_success
  end

  it 'creates a new kiosk' do
    expect { operation }.to change(Kiosk, :count).by 1
  end

  it 'creates a new layout' do
    expect { operation }.to change(KioskLayout, :count).by 1
  end

  context 'layout' do
    it 'creates a new navigation' do
      expect { operation }.to change(LayoutNavigation, :count).by 1
    end

    it 'creates a new navigation items' do
      expect { operation }.to change(LayoutNavigationItem, :count).by 1
    end

    it 'creates a kiosk assets' do
      expect { operation }.to change(KioskAsset, :count).by 2
    end

    it 'creates a new welcome asset' do
      expect { operation }.to change(WelcomeAsset, :count).by 1
    end

    it 'cloned kiosk with diff welcome asset' do
      operation

      expect(cloned_kiosk.layout.welcome_asset.asset).not_to be_nil
      expect(cloned_kiosk.layout.welcome_asset.asset.url).to match(/(\w){10}-yyy.jpeg$/)
    end

    it 'cloned kiosk with diff assets' do
      operation

      expect(cloned_kiosk.layout.kiosk_assets.first.asset).not_to be_nil
      expect(cloned_kiosk.layout.kiosk_assets.first.asset.url).to match(/(\w){10}-zzz.png$/)
    end
  end

  it 'filter criteria is custom' do
    operation

    expect(cloned_kiosk).to be_product_filter_criteria_custom
    expect(cloned_kiosk.product_filter_value_type).to be_nil
    expect(cloned_kiosk.product_filter_value_id).to be_nil
  end

  it 'cloned kiosk has no propducts' do
    operation

    expect(cloned_kiosk.kiosk_products.count).to eq 0
  end
end