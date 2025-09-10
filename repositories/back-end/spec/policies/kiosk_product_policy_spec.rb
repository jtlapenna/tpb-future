require 'rails_helper'

describe KioskProductPolicy do
  subject { described_class.new(user, resource) }

  let(:store) { build_stubbed :store }
  let(:kiosk) { build_stubbed :kiosk, store: store }
  let!(:resource) { build_stubbed :kiosk_product, kiosk: kiosk }
  let(:user) { build_stubbed :user, client: client }

  context 'with an admin' do
    let(:client) { nil }

    context 'without user' do
      let(:user) { nil }

      it { is_expected.to forbid_actions(%i[index new destroy create show update search]) }
    end

    context 'as admin' do
      let(:user) { create :user }

      it { is_expected.to permit_actions(%i[index new destroy create search]) }
    end

    context 'as client' do
      let(:user) { create :user_client }

      it { is_expected.to forbid_actions(%i[show update]) }
    end
  end

  context 'with a client' do
    let(:client) { create :client }
    let(:store) { create :store, client: client }
    let(:kiosk) { create :kiosk, store: store }
    let(:store_product) { create :store_product, store: store }
    let!(:resource) { create :kiosk_product, kiosk: kiosk, store_product: store_product }
    let(:user) { create :user, client: client }

    it { is_expected.to permit_actions(%i[index create show update destroy]) }
  end

  describe 'permitted attributes' do
    let(:user) { build :user }

    it { is_expected.to permit_mass_assignment_of(:store_product_id) }
  end
end
