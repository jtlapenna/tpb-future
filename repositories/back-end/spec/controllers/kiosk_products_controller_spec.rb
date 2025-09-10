require 'rails_helper'

describe KioskProductsController do
  let(:user) { create :user, client: client }
  let(:store) { create :store, client: client }
  let(:kiosk) { create :kiosk, store: store }
  let(:client) { nil }

  before { authenticate(user) }

  context '#index' do
    it 'respond ok' do
      get :index, params: { kiosk_id: kiosk.id }

      expect(response).to have_http_status :ok
    end

    context 'with a client' do
      let(:client) { create :client }
      let(:another_kiosk) { create :kiosk }

      it 'respond ok' do
        get :index, params: { kiosk_id: kiosk.id }

        expect(response).to have_http_status :ok
      end

      it 'respond not_found for another kiosk' do
        get :index, params: { kiosk_id: another_kiosk.id }

        expect(response).to have_http_status :not_found
      end
    end
  end

  context '#search' do
    let(:kiosk) { create :kiosk }

    before { get :search, params: { kiosk_id: kiosk.id } }

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#show' do
    let(:kiosk_product) { create(:kiosk_product, kiosk: kiosk) }

    it 'respond ok' do
      get :show, params: { kiosk_id: kiosk.id, id: kiosk_product.id }

      expect(response).to have_http_status :ok
    end

    context 'with a client' do
      let(:client) { create :client }
      let(:another_kiosk) { create :kiosk, store: store }

      it 'respond ok' do
        get :show, params: { kiosk_id: kiosk.id, id: kiosk_product.id }

        expect(response).to have_http_status :ok
      end

      it 'respond not_found for another kiosk' do
        get :show, params: { kiosk_id: another_kiosk.id, id: another_kiosk.id }

        expect(response).to have_http_status :not_found
      end
    end
  end

  context '#create' do
    let(:store_product) { create :store_product, store: store }

    let(:params) do
      {
        kiosk_id: kiosk.id,
        kiosk_products: [{ store_product_id: store_product.id }]
      }
    end

    it 'respond created' do
      post :create, params: params

      expect(response).to have_http_status :created
    end

    context 'with a client' do
      let(:client) { create :client }
      let(:another_kiosk) { create :kiosk }

      it 'respond created' do
        post :create, params: params

        expect(response).to have_http_status :created
      end

      it 'respond not_found for another kiosk' do
        post :create, params: params.merge(kiosk_id: another_kiosk.id)

        expect(response).to have_http_status :not_found
      end
    end
  end

  context '#update' do
    let(:kiosk_product) { create(:kiosk_product, kiosk: kiosk) }

    it 'respond ok' do
      put :update, params: {
        kiosk_id: kiosk.id,
        id: kiosk_product.id,
        kiosk_product: { id: kiosk_product.id }
      }

      expect(response).to have_http_status :ok
    end

    context 'with a client' do
      let(:client) { create :client }
      let(:another_kiosk) { create :kiosk, store: store }

      it 'respond ok' do
        put :update, params: { kiosk_id: kiosk.id, id: kiosk_product.id, kiosk_product: { id: kiosk_product.id } }

        expect(response).to have_http_status :ok
      end

      it 'respond not_found for another kiosk' do
        put :update, params: { kiosk_id: another_kiosk.id, id: another_kiosk.id }

        expect(response).to have_http_status :not_found
      end
    end
  end

  context '#destroy' do
    let(:kiosk_product) { create(:kiosk_product, kiosk: kiosk) }

    it 'respond ok' do
      delete :destroy, params: { kiosk_id: kiosk.id, id: kiosk_product.id }

      expect(response).to have_http_status :no_content
    end

    context 'with a client' do
      let(:client) { create :client }
      let(:another_kiosk) { create :kiosk, store: store }

      it 'respond ok' do
        delete :destroy, params: { kiosk_id: kiosk.id, id: kiosk_product.id }

        expect(response).to have_http_status :no_content
      end

      it 'respond not_found for another kiosk' do
        delete :destroy, params: { kiosk_id: another_kiosk.id, id: another_kiosk.id }

        expect(response).to have_http_status :not_found
      end
    end
  end
end
