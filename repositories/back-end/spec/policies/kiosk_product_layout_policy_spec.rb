require 'rails_helper'

describe KioskProductLayoutPolicy do
  let(:resource) {}

  it_behaves_like 'permitted actions only admin', actions: %i[index new create edit destroy]

  it_behaves_like 'permitted actions all users', actions: %i[show update]
end
