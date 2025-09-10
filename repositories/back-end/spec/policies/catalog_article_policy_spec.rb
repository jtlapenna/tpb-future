require 'rails_helper'

describe StoreArticlePolicy do
  let!(:resource) { build_stubbed :store_article }

  it_behaves_like 'permitted actions all users', actions: %i[index create update show destroy default_products]
end
