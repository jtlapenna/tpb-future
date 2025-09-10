require 'rails_helper'

describe CategoryPolicy do
  let!(:resource) { build_stubbed :category }

  it_behaves_like 'permitted actions only admin', actions: %i[create update show]

  it_behaves_like 'permitted actions all users', actions: [:index]
end
