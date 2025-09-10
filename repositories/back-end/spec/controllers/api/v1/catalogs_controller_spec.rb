require 'rails_helper'

describe Api::V1::CatalogsController do
  let(:kiosk) { create :kiosk }

  before { authenticate(kiosk.store) }

  context '#tags' do
    before { get :tags, params: { catalog_id: kiosk.id } }

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end

  context '#settings' do
    before { get :settings, params: { catalog_id: kiosk.id } }

    it 'respond ok' do
      expect(response).to have_http_status :ok
    end
  end
end
