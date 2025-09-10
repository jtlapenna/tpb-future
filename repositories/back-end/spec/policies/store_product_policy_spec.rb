require 'rails_helper'

describe StoreProductPolicy do
  subject { described_class.new(current_user, resource) }

  let!(:resource) { create :store_product }
  let(:store) { resource.store }

  it_behaves_like 'permitted actions all users', actions: %i[index update show create search destroy]

  describe 'permitted attributes' do
    let(:current_user) { build :user }

    it { is_expected.to permit_mass_assignment_of(:sku, :status).for_action(:create) }
    it { is_expected.to permit_mass_assignment_of(:sku, :status).for_action(:update) }

    context 'when user is a client' do
      let(:current_user) { build :user, client: create(:client) }

      it { is_expected.to permit_mass_assignment_of(:sku, :status).for_action(:create) }
      it { is_expected.to permit_mass_assignment_of(:sku, :status).for_action(:update) }

      context "when product's store has api integration" do
        before { store.update_attribute(:api_type, 'treez') }

        it { is_expected.to permit_mass_assignment_of(:sku, :status).for_action(:create) }
        it { is_expected.to permit_mass_assignment_of(:status).for_action(:update) }
        it { is_expected.to forbid_mass_assignment_of(:sku).for_action(:update) }
      end
    end
  end
end
