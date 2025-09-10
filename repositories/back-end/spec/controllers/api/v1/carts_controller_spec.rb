require 'rails_helper'

describe Api::V1::CartsController do
  let(:store) { create :store }
  let(:kiosk) { create :kiosk, store: store }

  before do
    store.regenerate_jti = false
    authenticate(store)
  end

  context '#validate' do
    let(:category) { create :store_category, store: store }
    let(:product) { create :store_product, store_category: category, weight: 2 }

    let(:params) do
      { cart: { items: [{ product_id: product.id, quanity: 1 }] }, catalog_id: kiosk.id }
    end

    it 'respond ok when validation succeed' do
      post :validate, params: params

      expect(response).to have_http_status :ok
    end

    it 'respond ok when validation fail' do
      store.settings.purchase_limits.create!(limit: 1, store_categories: [category], name: 'my limit')

      post :validate, params: params

      expect(response).to have_http_status :ok
    end

    it 'respond bad request when order parameter is missing' do
      post :validate, params: { catalog_id: kiosk.id }

      expect(response).to have_http_status :bad_request
    end
  end
end
