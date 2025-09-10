require 'rails_helper'

describe Api::V1::ProductsController do
  let(:kiosk) { create :kiosk }
  let(:store) { kiosk.store }

  before { authenticate(store) }

  context '#index' do
    before { get :index, params: { catalog_id: kiosk.id } }

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#similars' do
    context 'when product exists' do
      let(:product) { create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store) }

      before { get :similars, params: { id: product.store_product_id, catalog_id: kiosk.id } }

      it 'respond ok' do
        expect(response).to have_http_status :ok
      end
    end

    context "when product doesn't exists" do
      let(:product) { create :kiosk_product, kiosk: kiosk, store_product: create(:store_product, store: store) }

      before { get :similars, params: { id: -1, catalog_id: kiosk.id } }

      it 'respond ok' do
        expect(response).to have_http_status :not_found
      end
    end

    context 'when product is not from current store' do
      let(:product) { create :kiosk_product, store_product: create(:store_product) }

      before { get :similars, params: { id: product.store_product_id, catalog_id: kiosk.id } }

      it 'respond ok' do
        expect(response).to have_http_status :not_found
      end
    end
  end

  context '#maximal' do
    before { get :maximal, params: { catalog_id: kiosk.id } }

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end
end
