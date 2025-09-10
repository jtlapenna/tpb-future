require 'rails_helper'

describe ImagePolicy do
  context 'destroy' do
    let!(:resource) { build_stubbed :image }

    it_behaves_like 'permitted actions all users', actions: [:destroy]
  end

  context 'upload' do
    let!(:resource) { Image }

    it_behaves_like 'permitted actions all users', actions: [:upload_request]
  end
end
