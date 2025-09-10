require 'rails_helper'

describe 'Store Price API' do
  let(:store) { create :store }
  let(:user) { create :user }

  def price_json(price)
    price.as_json(only: %i[id name])
  end

  context '#index' do
    let(:prices) { store.store_prices.order(id: :desc) }
    let(:expected_prices) { prices.map { |c| price_json(c) } }

    before do
      create :store_price
      create_list :store_price, 3, store: store
      get store_store_prices_path(store), headers: auth_headers(user)
    end

    it 'respond with store prices' do
      expect(json).to have_key 'store_prices'
      expect(json['store_prices'].count).to eq 3
      expect(json['store_prices']).to eq expected_prices
    end
  end

  context '#index#sort' do
    let(:prices) { StorePrice.all.order(name: :asc) }
    let(:expected_prices) { prices.map { |c| price_json(c) } }

    before do
      create :store_price, name: 'Store 1', store: store
      create :store_price, name: 'Store 2', store: store
      create :store_price, name: 'Store 3', store: store
      get store_store_prices_path(store), params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted store prices' do
      expect(json).to have_key 'store_prices'
      expect(json['store_prices'].count).to eq 3
      expect(json['store_prices']).to eq expected_prices
    end
  end

  context '#create' do
    let(:price) { StorePrice.last }
    let(:params) { { store_price: { name: 'OMMP' } } }
    let(:missing_name_params) { { store_price: { name: '' } } }

    it 'create store price' do
      expect do
        post store_store_prices_path(store), params: params, headers: auth_headers(user)
      end.to change {
        store.store_prices.count
      }.by 1
    end

    it 'created store price' do
      post store_store_prices_path(store), params: params, headers: auth_headers(user)

      expect(price).to be
      expect(price.name).to eq 'OMMP'
      expect(price.store_id).to eq store.id
    end

    it 'respond with store price' do
      post store_store_prices_path(store), params: params, headers: auth_headers(user)

      expect(json).to have_key('store_price')
      expect(json['store_price']).to eq price_json(price)
    end

    it 'return errors' do
      post store_store_prices_path(store), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:params) { { store_price: { name: 'OMMP' } } }
    let(:price) { create :store_price, name: 'name', store: store }
    let(:missing_name_params) { { store_price: { name: '' } } }

    it 'update store price' do
      put store_store_price_path(store, price), params: params, headers: auth_headers(user)

      expect(price.reload.name).to eq 'OMMP'
    end

    it 'return updated store price' do
      put store_store_price_path(store, price), params: params, headers: auth_headers(user)

      expect(json).to have_key('store_price')
      expect(json['store_price']).to eq price_json(price.reload)
    end

    it 'return errors' do
      put store_store_price_path(store, price), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:price) { create :store_price, store: store }

    it 'return store price' do
      get store_store_price_path(store, price), headers: auth_headers(user)

      expect(json).to have_key('store_price')
      expect(json['store_price']).to eq price_json(price)
    end
  end
end
