require 'rails_helper'

describe KioskPolicy do
  subject { described_class.new(current_user, resource) }

  let!(:resource) { build_stubbed :kiosk }

  it_behaves_like 'permitted actions only admin', actions: %i[create clone]

  it_behaves_like 'permitted actions all users', actions: %i[index update show]
end
