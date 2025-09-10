require 'rails_helper'

describe 'API V1 Carts: validation' do
  let(:store) { create :store }
  let(:kiosk) { create :kiosk, store: store }
  let(:params) { cart_params([{ product_id: product.id, quantity: 3 }]) }
  let(:category) { create :store_category, store: store }
  let(:product) { create :store_product, store_category: category, weight: 2 }
  let(:success_response) do
    {
      success: true
    }.as_json
  end

  it 'respond with missing parameter' do
    post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: { xx: 1 }

    expect(json).to have_key 'message'
    expect(json['message']).to eq 'param is missing or the value is empty: cart'
  end

  it 'respond with error when quantity is zero' do
    post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: cart_params([{ product_id: product.id, quantity: 0 }])

    expect(json).to have_key 'message'
    expect(json['message']).to eq 'must be greater than 0'
    expect(json).to have_key 'errors'
    expect(json['errors']).to have_key 'cart.items.0.quantity'
  end

  it "succeed when store doesn't have limits" do
    post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

    expect(json).to eq success_response
  end

  context 'when store has one limite' do
    it 'fail when cart quantity is higher than limit' do
      store.settings.purchase_limits.create!(limit: 4, store_categories: [category], name: 'my limit')

      post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to eq error_response(name: 'my limit', max: 4, actual: 6, products: [product.id])
    end

    it 'should only return products that exists on the cart' do
      create :store_product, store_category: category

      store.settings.purchase_limits.create!(limit: 4, store_categories: [category], name: 'my limit')

      post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to eq error_response(name: 'my limit', max: 4, actual: 6, products: [product.id])
    end

    it 'succeed when product belongs to other category' do
      other_category = create :store_category, store: store
      store.settings.purchase_limits.create!(limit: 4, store_categories: [other_category], name: 'my limit')

      post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to eq success_response
    end
  end

  context 'when cart has two product of the same category' do
    let(:other_product) { create :store_product, store_category: category, weight: 3 }
    let(:params) do
      cart_params([{ product_id: product.id, quantity: 3 }, { product_id: other_product.id, quantity: 4 }])
    end

    it 'fail when sum of weights is higher than limit' do
      store.settings.purchase_limits.create!(limit: 14, store_categories: [category])

      post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to eq error_response(max: 14, actual: 18, products: [other_product.id, product.id])
    end

    it 'succeed when sum of weights is lower or equals than limit' do
      store.settings.purchase_limits.create!(limit: 18, store_categories: [category])

      post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to eq success_response
    end
  end

  it 'treats product weight as 0 when it is not defined' do
    product.update!(weight: nil)
    store.settings.purchase_limits.create!(limit: 18, store_categories: [category])

    post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

    expect(json).to eq success_response
  end

  context 'when store has two purchase limits' do
    it 'fails when weight is higher than second limit' do
      store.settings.purchase_limits.create!(limit: 6, store_categories: [category])
      store.settings.purchase_limits.create!(limit: 4, store_categories: [category])

      post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

      expect(json).to eq error_response(max: 4, actual: 6, products: [product.id])
    end
  end

  it 'succeed when weights for each category are lower than limits' do
    other_category = create :store_category, store: store
    other_product = create :store_product, store_category: other_category, weight: 3

    params = cart_params([{ product_id: product.id, quantity: 3 }, { product_id: other_product.id, quantity: 4 }])

    store.settings.purchase_limits.create!(limit: 6, store_categories: [category])
    store.settings.purchase_limits.create!(limit: 12, store_categories: [other_category])

    post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

    expect(json).to eq success_response
  end

  it 'fails when sum of weights of all categories are higher than limit' do
    other_category = create :store_category, store: store
    other_product = create :store_product, store_category: other_category, weight: 3

    params = cart_params([{ product_id: product.id, quantity: 3 }, { product_id: other_product.id, quantity: 4 }])

    store.settings.purchase_limits.create!(limit: 14, store_categories: [category, other_category])

    post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

    expect(json).to eq error_response(max: 14, actual: 18, products: [other_product.id, product.id])
  end

  it 'succeed when sum of weights of all categories is lower or equals than limit' do
    other_category = create :store_category, store: store
    other_product = create :store_product, store_category: other_category, weight: 3

    params = cart_params([{ product_id: product.id, quantity: 3 }, { product_id: other_product.id, quantity: 4 }])

    store.settings.purchase_limits.create!(limit: 18, store_categories: [category, other_category])

    post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

    expect(json).to eq success_response
  end

  it 'fail when any limit is reached' do
    other_category = create :store_category, store: store
    other_product = create :store_product, store_category: other_category, weight: 3
    third_product = create :store_product, store_category: other_category, weight: 5

    params = cart_params([{ product_id: other_product.id, quantity: 4 }, { product_id: product.id, quantity: 3 }, { product_id: third_product.id, quantity: 1 }])

    store.settings.purchase_limits.create!(limit: 6, store_categories: [category])
    store.settings.purchase_limits.create!(limit: 12, store_categories: [other_category])

    post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

    expect(json).to eq error_response(max: 12, actual: 17, products: [third_product.id, other_product.id])
  end

  it 'return all failing limits' do
    other_category = create :store_category, store: store
    other_product = create :store_product, store_category: other_category, weight: 3

    params = cart_params([{ product_id: other_product.id, quantity: 4 }, { product_id: product.id, quantity: 4 }])

    store.settings.purchase_limits.create!(limit: 2, store_categories: [category])
    store.settings.purchase_limits.create!(limit: 2, store_categories: [other_category])

    post validate_api_v1_catalogs_carts_path(kiosk.id), headers: auth_headers(store), params: params

    formatted_data = [{
      max: 2,
      actual: 8,
      products: [product.id]
    }, {
      max: 2,
      actual: 12,
      products: [other_product.id]
    }]

    expect(json).to eq error_response(formatted_data)
  end

  def cart_params(items)
    { cart: { items: items } }
  end

  def error_response(limits)
    {
      success: false,
      message: 'Sorry, you’re above the purchase limit. Please remove an item from your cart.',
      errors: {
        cart: [{
          code: 'purchase_limit',
          limits: [limits].flatten.map { |limit| response_limit(limit) },
          message: 'Sorry, you’re above the purchase limit. Please remove an item from your cart.'
        }]
      }
    }.as_json
  end

  def response_limit(options)
    defaults = { name: nil }

    rule = defaults.merge(options)
    rule[:products]&.sort!
    rule
  end
end
