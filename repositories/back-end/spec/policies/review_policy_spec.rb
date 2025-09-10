require 'rails_helper'

describe ReviewPolicy do
  let!(:resource) { build_stubbed :review }

  it_behaves_like 'permitted actions only admin'
end
