require 'rails_helper'

describe 'Brands API' do
  let(:user) { create :user }

  def brand_json(brand)
    includes = { logo: { only: %i[id url] } }
    b_json = brand.as_json(only: %i[id name description], include: includes)

    b_json['logo'] = nil unless brand.logo

    b_json
  end

  context '#index' do
    let(:brands) { Brand.all.order(id: :desc) }
    let(:expected_brands) { brands.map { |c| brand_json(c) } }

    before do
      create_list :brand, 3
      get brands_path, headers: auth_headers(user)
    end

    it 'respond with brands' do
      expect(json).to have_key('brands')
      expect(json['brands'].count).to eq 3
      expect(json['brands']).to eq expected_brands
    end
  end

  context '#index#sort' do
    let(:brands) { Brand.all.order(name: :asc) }
    let(:expected_brands) { brands.map { |c| brand_json(c) } }

    before do
      create :brand, name: 'Brand 3'
      create :brand, name: 'Brand 1'
      create :brand, name: 'Brand 2'
      get brands_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted brands' do
      expect(json).to have_key('brands')
      expect(json['brands'].count).to eq 3
      expect(json['brands']).to eq expected_brands
    end
  end

  context '#index#filter by brand name and description' do
    let(:brands) do
      [
        create(:brand, name: '1 Brand'),
        create(:brand, name: 'brand'),
        create(:brand, name: 'aBrand'),
        create(:brand, name: 'xxxx 3', description: 'brand 3')
      ]
    end
    let(:expected_brands) { brands.map { |c| brand_json(c) } }

    before do
      brands
      create :brand, name: 'xxxx 1'
      create :brand, name: 'xxxx 2'
      get brands_path, params: { q: 'brand' }, headers: auth_headers(user)
    end

    it 'respond with filtered brands' do
      expect(json).to have_key('brands')
      expect(json['brands'].count).to eq 4
      expect(json['brands']).to match_array expected_brands
    end
  end

  it_behaves_like 'paginated resource', Brand

  context '#create' do
    let(:brand) { Brand.last }
    let(:params) { { brand: { name: 'Brand 1', description: 'Brand description' } } }
    let(:missing_name_params) { { brand: { active: false } } }

    it 'create Brand' do
      expect do
        post brands_path, params: params, headers: auth_headers(user)
      end.to change {
        Brand.count
      }.by 1
    end

    it 'created brand values' do
      post brands_path, params: params, headers: auth_headers(user)

      expect(brand).to be
      expect(brand.name).to eq 'Brand 1'
    end

    it 'respond with brand' do
      post brands_path, params: params, headers: auth_headers(user)
      expect(json).to have_key('brand')
      expect(json['brand']).to eq brand_json(brand)
    end

    it 'return errors' do
      post brands_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:params) { { id: brand.id, brand: { name: 'new name' } } }
    let(:brand) { create :brand, name: 'brand' }
    let(:missing_name_params) { { brand: { name: '' } } }

    it 'update brand' do
      put brand_path(brand), params: params, headers: auth_headers(user)

      expect(brand.reload.name).to eq 'new name'
    end

    it 'return updated brand' do
      put brand_path(brand), params: params, headers: auth_headers(user)

      expect(json).to have_key('brand')
      expect(json['brand']).to eq brand_json(brand.reload)
    end

    it 'return errors' do
      put brand_path(brand), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end

    context 'with logo' do
      let(:params) do
        { id: brand.id,
          brand: {
            name: 'new name',
            logo_attributes: { id: brand.logo.id, url: 'new url 1' }
          } }
      end

      before do
        brand.logo = create(:asset, source: brand)
      end

      it 'update logo values' do
        put brand_path(brand), params: params, headers: auth_headers(user)

        expect(brand.reload).to be
        expect(brand.logo).to be
        expect(brand.logo.url).to eq 'new url 1'
      end
    end
  end

  context '#show' do
    let(:params) { { id: brand.id } }
    let(:brand) { create :brand, name: 'Brand' }

    it 'return brand' do
      get brand_path(brand), params: params, headers: auth_headers(user)

      expect(json).to have_key('brand')
      expect(json['brand']).to eq(brand_json(brand))
    end
  end
end
