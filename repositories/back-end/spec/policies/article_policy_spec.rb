require 'rails_helper'

describe ArticlePolicy do
  let!(:resource) { build_stubbed :article }

  it_behaves_like 'permitted actions only admin', actions: %i[create update]

  it_behaves_like 'permitted actions all users', actions: %i[index show]
end
