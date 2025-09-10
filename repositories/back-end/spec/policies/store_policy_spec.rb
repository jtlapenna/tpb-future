require 'rails_helper'

describe StorePolicy do
  subject { described_class.new(current_user, resource) }

  let!(:resource) { build_stubbed :store }

  context 'only admin' do
    it_behaves_like 'permitted actions only admin', actions: %i[new destroy edit create generate_token]
  end

  context 'all users' do
    it_behaves_like 'permitted actions all users', actions: %i[index show update]
  end

  describe 'permitted attributes' do
    let(:current_user) { build :user }

    it { is_expected.to permit_mass_assignment_of(:api_client_id) }
    it { is_expected.to permit_mass_assignment_of(:api_key) }
    it { is_expected.to permit_mass_assignment_of(:api_type) }
    it { is_expected.to permit_mass_assignment_of(:api_automatch) }
    it { is_expected.to permit_mass_assignment_of(:override_on_sync) }
    it { is_expected.to permit_mass_assignment_of(:dispensary_name) }
    it { is_expected.to permit_mass_assignment_of(:api_store_id) }
    it { is_expected.to permit_mass_assignment_of(:sync_frequency) }
    it { is_expected.to permit_mass_assignment_of(:sync_frequency_offset) }
    it { is_expected.to permit_mass_assignment_of(:api_version) }
    it { is_expected.to permit_mass_assignment_of(:notifications_enabled) }
    it { is_expected.to permit_mass_assignment_of(:notifications_title) }
    it { is_expected.to permit_mass_assignment_of(:notifications_intro) }
    it { is_expected.to permit_mass_assignment_of(notifications_recipients: []) }
    it { is_expected.to permit_mass_assignment_of(:enabled_share_email_product) }
    it { is_expected.to permit_mass_assignment_of(:enabled_share_sms_product) }
    it { is_expected.to permit_mass_assignment_of(:sync_tags) }
    it { is_expected.to permit_mass_assignment_of(:location_id) }
    it { is_expected.to permit_mass_assignment_of(:auth0_client_id) }
    it { is_expected.to permit_mass_assignment_of(:auth0_client_secret) }

    it { is_expected.to forbid_mass_assignment_of(:notifications_recipients) }

    context 'when user is a client' do
      let(:current_user) { build :user, client: create(:client) }

      it { is_expected.to permit_mass_assignment_of(:enabled_share_email_product) }
      it { is_expected.to permit_mass_assignment_of(:enabled_share_sms_product) }
      it { is_expected.to permit_mass_assignment_of(:notifications_enabled) }
      it { is_expected.to permit_mass_assignment_of(:notifications_title) }
      it { is_expected.to permit_mass_assignment_of(:notifications_intro) }
      it { is_expected.to permit_mass_assignment_of(notifications_recipients: []) }

      it { is_expected.to forbid_mass_assignment_of(:notifications_recipients) }

      it { is_expected.to forbid_mass_assignment_of(:api_client_id) }
      it { is_expected.to forbid_mass_assignment_of(:api_key) }
      it { is_expected.to forbid_mass_assignment_of(:api_type) }
      it { is_expected.to forbid_mass_assignment_of(:api_automatch) }
      it { is_expected.to forbid_mass_assignment_of(:override_on_sync) }
      it { is_expected.to forbid_mass_assignment_of(:dispensary_name) }
      it { is_expected.to forbid_mass_assignment_of(:api_store_id) }
      it { is_expected.to forbid_mass_assignment_of(:sync_frequency) }
      it { is_expected.to forbid_mass_assignment_of(:sync_frequency_offset) }
      it { is_expected.to forbid_mass_assignment_of(:api_version) }
      it { is_expected.to forbid_mass_assignment_of(:client_id) }
      it { is_expected.to forbid_mass_assignment_of(:sync_tags) }
      it { is_expected.to forbid_mass_assignment_of(:location_id) }
      it { is_expected.to forbid_mass_assignment_of(:auth0_client_id) }
      it { is_expected.to forbid_mass_assignment_of(:auth0_client_secret) }
    end
  end
end
