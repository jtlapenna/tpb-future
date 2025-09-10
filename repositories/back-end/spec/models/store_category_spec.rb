require 'rails_helper'

describe StoreCategory do
  let(:category) { build_stubbed :store_category }

  it 'is valid' do
    expect(category).to be_valid
  end

  it 'is not valid without name' do
    category.name = nil
    expect(category).not_to be_valid
  end

  it 'is not valid without store' do
    category.store = nil
    expect(category).not_to be_valid
  end
end
