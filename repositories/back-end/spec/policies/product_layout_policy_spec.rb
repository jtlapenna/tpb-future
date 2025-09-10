require 'rails_helper'

describe ProductLayoutPolicy do
  let(:resource) { build_stubbed :product_layout }

  it_behaves_like 'permitted actions only admin', actions: %i[new update index destroy edit create]

  it_behaves_like 'permitted actions all users', actions: [:show]
end
