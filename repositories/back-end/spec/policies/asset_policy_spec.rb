require 'rails_helper'

describe AssetPolicy do
  let!(:resource) { build_stubbed :asset }

  context 'assets' do
    let!(:resource) { build_stubbed :asset }

    it_behaves_like 'permitted actions only admin', actions: %i[upload_request destroy]
  end

  context 'images destroy' do
    let!(:resource) { build_stubbed :image }

    it_behaves_like 'permitted actions all users', actions: [:destroy]
  end

  context 'images update' do
    let!(:resource) { Image }

    it_behaves_like 'permitted actions all users', actions: [:upload_request]
  end
end
