require 'rails_helper'

describe LayoutPositionPolicy do
  let!(:resource) { build_stubbed :layout_position }

  it_behaves_like 'permitted actions only admin'
end
