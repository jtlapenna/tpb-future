require 'rails_helper'

describe RfidProductsController do
  let(:user) { create :user }
  let(:kiosk_product) { create :kiosk_product }

  before { authenticate(user) }

  context '#index' do
    before { get :index, params: { kiosk_id: kiosk_product.kiosk_id } }

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#create' do
    let(:params) do
      {
        kiosk_id: kiosk_product.kiosk_id,
        rfid_product: { rfid: '1', kiosk_product_id: kiosk_product.id }
      }
    end

    before { post :create, params: params }

    it 'respond ok' do
      expect(response).to have_http_status :created
    end
  end
end
