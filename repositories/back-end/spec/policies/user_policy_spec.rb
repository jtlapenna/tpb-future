require 'rails_helper'

describe UserPolicy do
  let(:resource) { build_stubbed :user }

  context 'as admin' do
    subject { described_class.new(current_user, resource) }

    let(:current_user) { build :user }

    context 'working with himself' do
      let(:resource) { current_user }

      it { is_expected.to permit_actions %i[index new update index destroy edit create] }
    end

    context 'working with other user' do
      it { is_expected.to permit_actions %i[index new update index destroy edit create] }
    end
  end

  context 'as client' do
    subject { described_class.new(current_user, resource) }

    let(:current_user) { build :user_client }

    context 'working with himself' do
      let(:resource) { current_user }

      it { is_expected.to permit_actions %i[update show] }
      it { is_expected.to forbid_actions %i[index create destroy] }
    end

    context 'working with other user' do
      it { is_expected.to forbid_actions %i[index create destroy update show] }
    end
  end
end
