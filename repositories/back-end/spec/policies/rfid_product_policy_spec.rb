require 'rails_helper'

describe RfidProductPolicy do
  let!(:resource) { build_stubbed :rfid_product }

  it_behaves_like 'permitted actions all users', actions: %i[index create]
end
