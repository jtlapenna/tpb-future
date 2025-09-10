require 'rails_helper'

describe 'Store Categories API' do
  include SerializationHelper::Stores

  let(:user) { create :user }

  def category_json(category, minimal: false)
    category_json = category.as_json(only: %i[id name order store_id])

    extra = {}
    unless minimal
      extra = {
        'store' => category.store.as_json(only: %i[id name]),
        'banner' => asset_json(category.banner)
      }
    end

    category_json.merge(extra)
  end

  context '#index' do
    let(:categories) { StoreCategory.all.order(id: :desc) }
    let(:expected_categories) { categories.map { |c| category_json(c, minimal: true) } }
    let(:store) { create :store, categories_count: 3 }

    before { get store_store_categories_path(store), headers: auth_headers(user) }

    it 'respond with categories' do
      expect(json).to have_key('store_categories')
      expect(json['store_categories'].count).to eq 3
      expect(json['store_categories']).to eq expected_categories
    end
  end

  context '#index#sort' do
    let(:store) { create :store, categories_count: 0 }
    let(:categories) { StoreCategory.all.order(order: :asc) }
    let(:expected_categories) { categories.map { |c| category_json(c, minimal: true) } }

    before do
      create :store_category, name: 'StoreCategory 3', store: store, order: 10
      create :store_category, name: 'StoreCategory 1', store: store, order: 30
      create :store_category, name: 'StoreCategory 2', store: store, order: 20
      get store_store_categories_path(store),
          params: { sort_by: 'order', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted products' do
      expect(json).to have_key('store_categories')
      expect(json['store_categories'].count).to eq 3
      expect(json['store_categories']).to eq expected_categories
    end
  end

  context '#index#filter' do
    let(:store) { create :store, categories_count: 0 }
    let(:store2) { create :store, categories_count: 0 }
    let!(:expected_attributes) do
      [
        create(:store_category, name: 'Attribute 1', store: store),
        create(:store_category, name: 'Attribute 2', store: store)
      ].map { |c| category_json(c, minimal: true) }
    end

    before do
      create :store_category, name: 'Attribute 3', store: store2
      get store_store_categories_path(store), params: { store_id: store.id, sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with filtered attributes' do
      expect(json).to have_key('store_categories')
      expect(json['store_categories'].count).to eq 2
      expect(json['store_categories']).to eq expected_attributes
    end
  end

  it_behaves_like 'paginated resource', StoreCategory do
    let(:store) { create :store, categories_count: 0 }
    let(:path) { store_store_categories_path(store) }

    before do
      StoreCategory.destroy_all
      create_list :store_category, 15, store: store
    end
  end

  context '#create' do
    let(:store) { create :store, categories_count: 0 }
    let(:category) { StoreCategory.last }
    let(:params) { { store_category: { name: 'Category 1', order: 10, banner_attributes: { url: 'banner (url)' } } } }
    let(:missing_name_params) { { store_category: { name: '' } } }

    it 'create category' do
      expect do
        post store_store_categories_path(store), params: params, headers: auth_headers(user)
      end.to change {
        store.store_categories.count
      }.by 1

      expect(category.banner).to have_attributes url: 'banner (url)'
    end

    it 'respond with category' do
      post store_store_categories_path(store), params: params, headers: auth_headers(user)

      expect(json).to have_key('store_category')
      expect(json['store_category']).to eq category_json(category)
    end

    it 'return errors' do
      post store_store_categories_path(store), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:store) { create :store, categories_count: 0 }
    let(:params) { { id: category.id, store_category: { name: 'new name' } } }
    let(:category) { create :store_category, name: 'Category', store: store }
    let(:missing_name_params) { { store_category: { name: '' } } }

    it 'update category' do
      put store_store_category_path(store, category), params: params, headers: auth_headers(user)

      expect(category.reload.name).to eq 'new name'
    end

    it 'return updated category' do
      put store_store_category_path(store, category), params: params, headers: auth_headers(user)

      expect(json).to have_key('store_category')
      expect(json['store_category']).to eq category_json(category.reload)
    end

    it 'return errors' do
      put store_store_category_path(store, category), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:params) { { id: category.id } }
    let(:category) { create :store_category, name: 'Store Category' }

    it 'return category' do
      get store_store_category_path(category.store, category), params: params, headers: auth_headers(user)

      expect(json).to have_key('store_category')
      expect(json['store_category']).to eq(category_json(category, minimal: false))
    end
  end

  context '#destroy' do
    let(:params) { { id: category.id } }
    let(:category) { create :store_category, name: 'Catalog Category' }
    let(:store) { category.store }

    it 'destroy category' do
      expect do
        delete store_store_category_path(category.store, category), params: params, headers: auth_headers(user)
      end.to change {
        store.store_categories.count
      }.by -1
    end

    it 'do not destroy if category has products' do
      create :store_product, store_category: category

      expect do
        delete store_store_category_path(category.store, category), params: params, headers: auth_headers(user)
      end.not_to change {
        store.store_categories.count
      }

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('category_not_empty')
      expect(json['errors']).to eq('category_not_empty' => ['Can not delete a category with products'])
    end
  end
end
