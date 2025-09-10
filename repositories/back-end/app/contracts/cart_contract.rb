class CartContract < Dry::Validation::Contract
  config.messages.backend = :i18n
  config.messages.namespace = :cart

  option :store

  params do
    required(:cart).hash do
      required(:items).array(:hash) do
        required(:product_id).filled(:integer)
        required(:quantity).filled(:integer, gt?: 0)
      end
    end
  end

  rule(:cart) do
    category_info = category_info(value[:items])

    limit_status = purchase_limits.map do |purchase_limit|
      state = {
        name: purchase_limit.name,
        max: purchase_limit.limit
      }

      weights = purchase_limit.store_category_ids.map { |category| category_info[category][:weight] }
      products = purchase_limit.store_category_ids.map { |category| category_info[category][:products] }

      state[:actual] = weights.sum
      state[:products] = products.flatten.sort
      state
    end

    purchase_limits_exceeded = limit_status.select { |state| state[:max] < state[:actual] }

    if purchase_limits_exceeded.present?
      key.failure(text: :purchase_limit, code: :purchase_limit, limits: purchase_limits_exceeded)
    end
  end

  private

  def purchase_limits
    store.settings.purchase_limits
  end

  def category_info(cart_items)
    items_info = cart_items.map do |item|
      store_product = store.store_products.find(item[:product_id])
      weight = store_product.weight.to_i
      category = store_product.store_category_id
      quantity = item[:quantity].to_i

      [item[:product_id].to_i, category, quantity * weight]
    end

    info = Hash.new do |hash, key|
      hash[key] = { weight: 0, products: [] }
    end

    items_info.each_with_object(info) do |item_weight, dic|
      product_id, category, weight = item_weight

      dic[category][:weight] += weight
      dic[category][:products] << product_id
    end
  end
end
