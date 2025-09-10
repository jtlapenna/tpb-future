require 'rails_helper'

describe ActsAsTaggableOn::TagPolicy do
  let!(:resource) { ActsAsTaggableOn::Tag }

  it_behaves_like 'permitted actions all users', actions: [:index]
end
