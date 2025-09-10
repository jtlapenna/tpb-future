require 'rails_helper'

describe BrandPolicy do
  let!(:resource) { build_stubbed :brand }

  it_behaves_like 'permitted actions only admin', actions: %i[new update show destroy edit create]

  it_behaves_like 'permitted actions all users', actions: [:index]
end
