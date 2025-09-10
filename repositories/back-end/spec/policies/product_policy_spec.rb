require 'rails_helper'

describe ProductPolicy do
  let!(:resource) { build_stubbed :product }

  it_behaves_like 'permitted actions only admin', actions: %i[new update destroy edit create]

  it_behaves_like 'permitted actions all users', actions: %i[index search show tags]
end
