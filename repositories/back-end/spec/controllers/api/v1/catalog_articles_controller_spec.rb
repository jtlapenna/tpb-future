require 'rails_helper'

describe Api::V1::CatalogArticlesController do
  let(:kiosk) { create :kiosk }

  before { authenticate(kiosk.store) }

  context '#index' do
    before { get :index, params: { catalog_id: kiosk.id } }

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end
end
