require 'rails_helper'

describe ProductVariantPolicy do
  let!(:resource) { build_stubbed :product_variant }

  it_behaves_like 'permitted actions only admin', actions: %i[new destroy edit update create]

  it_behaves_like 'permitted actions all users', actions: %i[index show tags search]
end
