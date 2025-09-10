require 'rails_helper'

describe StoreCategoryPolicy do
  let(:current_user) { build_stubbed :user }
  let!(:resource) { build_stubbed :store_category }

  subject { described_class.new(current_user, resource) }

  it_behaves_like 'permitted actions all users', actions: %i[index create update show]

  it { is_expected.to permit_mass_assignment_of(:name) }
  it { is_expected.to permit_mass_assignment_of(:order) }

  context 'when user is a client' do
    let(:current_user) { build :user, client: create(:client) }

    it { is_expected.to permit_mass_assignment_of(:name) }
    it { is_expected.to permit_mass_assignment_of(:order) }
  end
end
