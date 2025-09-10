require 'rails_helper'

RSpec.describe PurchaseLimit, type: :model do
  let(:limit) { build_stubbed :purchase_limit }

  it 'is valid' do
    expect(limit).to be_valid
  end

  it 'is not valid without a limit' do
    limit.limit = nil
    expect(limit).not_to be_valid
  end

  it 'is not valid without a category' do
    limit.store_categories = []
    expect(limit).not_to be_valid
  end

  it 'is not valid with limit zero' do
    limit.limit = 0
    expect(limit).not_to be_valid
  end

  it 'is not valid when limit is decimal' do
    limit.limit = 0.5
    expect(limit).not_to be_valid
  end
end
