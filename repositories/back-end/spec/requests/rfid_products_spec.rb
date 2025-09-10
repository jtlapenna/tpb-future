require 'rails_helper'

describe 'RFID products' do
  let(:user) { create :user }
  let(:kiosk_product) { create :kiosk_product, kiosk: kiosk, store_product: store_product }
  let(:store_product) { create :store_product, store: store }
  let(:kiosk) { create :kiosk, store: store }
  let(:store) { create :store }

  def rfid_product_json(rfid)
    rfid_json = rfid.as_json(only: %i[id rfid rfid_entity_id rfid_entity_type])
    rfid_json['stock'] = rfid.rfid_entity.stock if rfid.rfid_entity_type == 'KioskProduct'
    rfid_json
  end

  context '#index' do
    let(:rfids) { RfidProduct.all.order(id: :asc) }
    let(:expected_rfids) { rfids.map { |r| rfid_product_json(r) } }

    before do
      create_list :rfid_product, 3, rfid_entity: create(:kiosk_product, kiosk: kiosk, store_product: create(:store_product))
      get kiosk_rfid_products_path(kiosk_product.kiosk_id), headers: auth_headers(user)
    end

    it 'respond with rfids' do
      expect(json).to have_key('rfid_products')
      expect(json['rfid_products'].count).to eq 3
      expect(json['rfid_products']).to eq expected_rfids
    end
  end

  context '#create' do
    let(:params) do
      {
          rfid_product: { rfid: '1', rfid_entity_id: kiosk_product.id, rfid_entity_type: 'KioskProduct' }
      }
    end

    it 'create rfid product on kiosk' do
      expect do
        post kiosk_rfid_products_path(kiosk_product.kiosk_id), params: params, headers: auth_headers(user)
      end.to change {
        kiosk.rfid_products.count
      }.by 1
    end
  end
end
