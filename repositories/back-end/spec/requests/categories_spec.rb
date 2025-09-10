require 'rails_helper'

describe 'Categories API' do
  let(:user) { create :user }

  def category_json(category)
    category.as_json(only: %i[id name])
  end

  context '#index' do
    let(:categories) { Category.all.order(id: :desc) }
    let(:expected_categories) { categories.map { |c| category_json(c) } }

    before do
      create_list :category, 3
      get categories_path, headers: auth_headers(user)
    end

    it 'respond with categories' do
      expect(json).to have_key('categories')
      expect(json['categories'].count).to eq 3
      expect(json['categories']).to eq expected_categories
    end
  end

  context '#index#sort' do
    let(:categories) { Category.all.order(name: :asc) }
    let(:expected_categories) { categories.map { |c| category_json(c) } }

    before do
      create :category, name: 'category 3'
      create :category, name: 'category 1'
      create :category, name: 'category 2'
      get categories_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted products' do
      expect(json).to have_key('categories')
      expect(json['categories'].count).to eq 3
      expect(json['categories']).to eq expected_categories
    end
  end

  it_behaves_like 'paginated resource', Category

  context '#create' do
    let(:category) { Category.last }
    let(:params) { { category: { name: 'Category 1' } } }
    let(:missing_name_params) { { category: { name: '' } } }

    it 'create category' do
      expect do
        post categories_path, params: params, headers: auth_headers(user)
      end.to change {
        Category.count
      }.by 1
    end

    it 'respond with product' do
      post categories_path, params: params, headers: auth_headers(user)

      expect(json).to have_key('category')
      expect(json['category']).to eq category_json(category)
    end

    it 'return errors' do
      post categories_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:params) { { id: category.id, category: { name: 'new name' } } }
    let(:category) { create :category, name: 'Category' }
    let(:missing_name_params) { { category: { name: '' } } }

    it 'update category' do
      put category_path(category), params: params, headers: auth_headers(user)

      expect(category.reload.name).to eq 'new name'
    end

    it 'return updated category' do
      put category_path(category), params: params, headers: auth_headers(user)

      expect(json).to have_key('category')
      expect(json['category']).to eq category_json(category.reload)
    end

    it 'return errors' do
      put category_path(category), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:params) { { id: category.id } }
    let(:category) { create :category, name: 'Category' }

    it 'return category' do
      get category_path(category), params: params, headers: auth_headers(user)

      expect(json).to have_key('category')
      expect(json['category']).to eq(category_json(category))
    end
  end
end
