require 'rails_helper'

describe StoreSyncPolicy do
  let!(:resource) { build_stubbed :store_sync }

  it_behaves_like 'permitted actions all users', actions: %i[create show sync_item finish]
end
