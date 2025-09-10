require 'rails_helper'

describe KioskProductLayoutsController do
  let(:user) { create :user, client: client }
  let(:store) { create :store, client: client }
  let(:kiosk) { create :kiosk, store: store }
  let(:client) { nil }

  before { authenticate(user) }

  context '#show' do
    let(:kiosk_product) { create(:kiosk_product, kiosk: kiosk) }

    it 'respond ok' do
      get :show, params: { kiosk_id: kiosk.id, kiosk_product_id: kiosk_product.id }

      expect(response).to have_http_status :ok
    end

    context 'with a client' do
      let(:client) { create :client }
      let(:another_kiosk) { create :kiosk, store: store }

      it 'respond ok' do
        get :show, params: { kiosk_id: kiosk.id, kiosk_product_id: kiosk_product.id }

        expect(response).to have_http_status :ok
      end

      it 'respond not_found for another kiosk' do
        get :show, params: { kiosk_id: another_kiosk.id, kiosk_product_id: kiosk_product.id }

        expect(response).to have_http_status :not_found
      end
    end
  end

  context '#update' do
    let(:kiosk_product) { create(:kiosk_product, kiosk: kiosk) }

    it 'respond ok' do
      put :update, params: {
        kiosk_id: kiosk.id,
        kiosk_product_id: kiosk_product.id,
        kiosk_product_layout: { values: [{ _destroy: true }] }
      }

      expect(response).to have_http_status :ok
    end

    context 'with a client' do
      let(:client) { create :client }
      let(:another_kiosk) { create :kiosk, store: store }

      it 'respond ok' do
        put :update, params: { kiosk_id: kiosk.id, kiosk_product_id: kiosk_product.id, kiosk_product_layout: { values: [{ _destroy: true }] } }

        expect(response).to have_http_status :ok
      end

      it 'respond not_found for another kiosk' do
        put :update, params: { kiosk_id: another_kiosk.id, kiosk_product_id: kiosk_product.id }

        expect(response).to have_http_status :not_found
      end
    end
  end
end
