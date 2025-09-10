require 'rails_helper'

describe Category do
  let(:category) { build_stubbed :category }

  it 'is valid' do
    expect(category).to be_valid
  end

  it 'is not valid without name' do
    category.name = nil
    expect(category).not_to be_valid
    expect(category.errors[:name]).to eq ["can't be blank"]
  end

  context 'name' do
    let(:category) { create :category }

    it 'must be unique' do
      another_category = build :category, name: category.name
      expect(another_category).not_to be_valid
      expect(another_category.errors[:name]).to eq ['has already been taken']
    end
  end
end
