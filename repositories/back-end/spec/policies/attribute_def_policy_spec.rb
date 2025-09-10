require 'rails_helper'

describe AttributeDefPolicy do
  let!(:resource) { build_stubbed :attribute_def }

  it_behaves_like 'permitted actions only admin', actions: %i[new update destroy edit create]

  it_behaves_like 'permitted actions all users', actions: %i[show index]
end
