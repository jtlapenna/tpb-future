shared_examples 'permitted actions only admin' do |actions: %i[index new update show destroy edit create]|
  subject { described_class.new(current_user, resource) }

  context 'without user' do
    let(:current_user) { nil }

    it { is_expected.to forbid_actions(actions) }
  end

  context 'as admin' do
    let(:current_user) { create :user }

    it { is_expected.to permit_actions(actions) }
  end

  context 'as client' do
    let(:current_user) { create :user_client }

    it { is_expected.to forbid_actions(actions) }
  end
end

shared_examples 'permitted actions all users' do |actions: %i[index new update show destroy edit create]|
  subject { described_class.new(current_user, resource) }

  context 'without user' do
    let(:current_user) { nil }

    it { is_expected.to forbid_actions(actions) }
  end

  context 'as admin' do
    let(:current_user) { create :user }

    it { is_expected.to permit_actions(actions) }
  end

  context 'as client' do
    let(:current_user) { create :user_client }

    it { is_expected.to permit_actions(actions) }
  end
end
