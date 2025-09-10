require 'rails_helper'

describe TagInfoPolicy do
  let!(:resource) { build_stubbed :tag_info }

  it_behaves_like 'permitted actions only admin'
end
