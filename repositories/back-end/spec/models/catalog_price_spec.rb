require 'rails_helper'

describe StorePrice do
  let(:price) { build_stubbed :store_price }

  it 'is valid' do
    expect(price).to be_valid
  end

  describe 'name' do
    let(:price) { create :store_price }

    it 'name is unique by catalog' do
      dup_price = build :store_price, store: price.store, name: price.name

      expect(dup_price).not_to be_valid
    end

    it 'duplicate name is allowed on another catalog' do
      dup_price = build :store_price, name: price.name

      expect(dup_price).to be_valid
    end
  end
end
