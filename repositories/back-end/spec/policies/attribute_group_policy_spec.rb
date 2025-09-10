require 'rails_helper'

describe AttributeGroupPolicy do
  let!(:resource) { build_stubbed :attribute_group }

  it_behaves_like 'permitted actions only admin', actions: %i[new update show destroy edit create]

  it_behaves_like 'permitted actions all users', actions: [:index]
end
