require 'rails_helper'

describe KioskLayoutPolicy do
  let!(:resource) { build_stubbed :kiosk_layout }

  it_behaves_like 'permitted actions only admin'
end
