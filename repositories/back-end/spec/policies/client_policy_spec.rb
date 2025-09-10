require 'rails_helper'

describe ClientPolicy do
  let(:resource) { build_stubbed :client }

  context 'only admin' do
    it_behaves_like 'permitted actions only admin', actions: %i[new update index destroy edit create]
  end

  context 'all users' do
    it_behaves_like 'permitted actions all users', actions: [:show]
  end
end
