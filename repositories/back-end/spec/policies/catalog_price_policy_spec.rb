require 'rails_helper'

describe StorePricePolicy do
  let!(:resource) { build_stubbed :store_price }

  it_behaves_like 'permitted actions all users', actions: %w[index create update show]
end
