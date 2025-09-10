require 'rails_helper'

describe Brand do
  let(:brand) { build_stubbed :brand }

  it 'is valid' do
    expect(brand).to be_valid
  end

  it 'is not valid without name' do
    brand.name = nil
    expect(brand).not_to be_valid
  end

  describe 'name' do
    let!(:brand) { create :brand }

    it 'should be unique' do
      another_brand = build :brand, name: brand.name

      expect(another_brand).not_to be_valid
      expect(another_brand.errors[:name]).to eq ['has already been taken']
    end

    context 'search brand by name' do
      let!(:anotherBrand) { create :brand, name: 'ABSOLUTE XTRACTS' }
      let(:expected_brands) { [anotherBrand] }

      it 'case and space insensitive' do
        expect(Brand.name_equal('ABSOLUTE XTRACTS').compact).to eq expected_brands
        expect(Brand.name_equal('ABsoluTExtracts').compact).to eq expected_brands
        expect(Brand.name_equal('ABSOLUTE      XTRACTS').compact).to eq expected_brands
        expect(Brand.name_equal('  ABSOLUTE xtracts  ').compact).to eq expected_brands
      end
    end
  end
end
