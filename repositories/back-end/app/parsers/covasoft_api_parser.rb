require 'csv'

class CovasoftApiParser
  def initialize(store_id:)
    @store_id = store_id
  end

  def store
    @store ||= Store.find(@store_id)
  end

  def parse
    store_sync = StoreSync.new(store_id: @store_id)
    result = { errors: [], sync: nil }
    errors = []
    is_initial_sync = false
    next_initial_sync = store.next_initial_sync
    formatted_next_initial_sync = Date.today.strftime("%Y-%m-%d")
    products_ids_include_in_api = []
    enabled_automate_promotions = store[:api_settings][:enable_automate_promotions]
    store_products = StoreProduct.where(store_id: @store_id)
    promotions = nil
    products_for_promotions = nil
    products_ids_with_promotions_save = []

    Rails.logger.info("Promotion Debug: Automate promotions enabled: #{enabled_automate_promotions}")

    if next_initial_sync.nil? || next_initial_sync == formatted_next_initial_sync
      is_initial_sync = true
    end

    if enabled_automate_promotions
      promotions = product_promotions
      Rails.logger.info("Promotion Debug: Retrieved #{promotions&.size || 0} promotions from API")
      Rails.logger.info("Promotion Debug: All Promotions #{promotions.to_json}")
      store_products_promotions = StoreProductPromotion.where(store_product_id: store_products.map(&:id))

      unless is_initial_sync
        products_for_promotions = get_products(store_products)
      end
    end

    products_grouped_by_sku = store_products.group_by(&:sku)

    begin
      products_grouped_by_sku.each do |sku, products|
        next if products.size <= 1

        products_sorted = products.sort_by { |product| [product.stock, product.created_at] }

        products_to_remove = products_sorted[1..-1]
        product_to_keep = products_sorted.first

        products_to_remove.each do |product|
          DuplicatedSkuDeletedLog.create!(
            store_id: @store_id,
            store_product_id: product_to_keep.id,
            deleted_sku: product.sku,
            deleted_store_product_id: product.id
          )
        end

        products_to_remove.each(&:destroy)
      end
    rescue StandardError => e
      Sentry.capture_exception(e, level: :warning)
      puts "Error while removing duplicated SKUs: #{e.message}"
      Rails.logger.error("Error while removing duplicated SKUs: #{e.message}")
    end

    inventory_products.each_with_index do |api_product, index|
      product_stock = safe_stock(api_product[:Availability])
      # Automate promotions
      if enabled_automate_promotions && is_initial_sync && !promotions.nil? && !promotions.empty?
        product_with_promotion = get_product_promotion(api_product, promotions)
        was_not_removed = true
        if api_client.is_green_haven_store?(@store_id)
          unless promotion_active?(product_with_promotion[:promotion])
            Rails.logger.info("Promotion Debug: Promotion inactive, removing promotion for product #{api_product[:ProductId]}")
            remove_promotion(api_product[:ProductId], store_products, store_products_promotions, product_with_promotion[:promotion][:Id])
            was_not_removed = false
          end
        end
        if product_with_promotion[:price_discount] > 0 && !product_with_promotion[:promotion].nil? && was_not_removed
          Rails.logger.info("Promotion Debug: Found valid promotion for product #{api_product[:ProductId]} with discount: #{product_with_promotion[:price_discount]}")
          store_product_id = store_products.find { |store_product| store_product.sku == api_product[:ProductId] }&.id
          products_ids_with_promotions_save << store_product_id
          save_promotions(product_with_promotion[:promotion], api_product, store_products, product_with_promotion[:price_discount])
        else
          remove_promotions(api_product[:ProductId], store_products, store_products_promotions)
        end
      end
      products_ids_include_in_api << api_product[:ProductId]
      weight = get_weight(api_product)
      prices = api_product[:Prices].map do |productPrice|
        if productPrice[:AtTierPrice].nil?
          productPriceValue = (productPrice[:SalePrices] != nil && productPrice[:SalePrices] != []) ? productPrice[:SalePrices][0][:SalePrice] : productPrice[:Price]
          { name: weight != nil ? "#{weight}g" : "Each" , value: productPriceValue }
        else
          productPriceValue = (productPrice[:SalePrices] != nil && productPrice[:SalePrices] != []) ? productPrice[:SalePrices][0][:SalePrice] : productPrice[:AtTierPrice]
          { name: productPrice[:TierName], value: productPriceValue }
        end
      end
      begin
        attributes = %w[thc cbd strain].map { |attr_name| product_attribute(attr_name, api_product) }.compact
      rescue StandardError => e
        Sentry.capture_exception(e)
        attributes = []
      end
      begin
        images = {}
        if api_product[:Assets] && api_product[:Assets] != nil && api_product[:Assets] != []
          images[:primary] = api_product[:Assets][0][:Uri]
          images[:thumb] = api_product[:HeroShotUri]
        end
      rescue StandardError => e
        Sentry.capture_exception(e)
        images = {}
      end

      item = StoreSyncItem.new(
        sku: api_product[:ProductId],
        name: api_product[:Name],
        description: sanitize_html(api_product[:LongDescription]),
        weight: weight != nil ? (weight * 1000).to_i : nil,
        category: api_product[:ClassificationName],
        stock: product_stock,
        brand: get_brand(api_product),
        store_sync: store_sync,
        active: true,
        prices: prices,
        images: images,
        tags: get_tags(api_product),
        attributes_values: attributes
      )

      if item.valid?
        store_sync.store_sync_items << item
      else
        # Index is 0 based
        result[:errors] << { row: index + 1, messages: item.errors.messages }
      end
    end

    if is_initial_sync
      store_products.each do |store_product|
        if !products_ids_include_in_api.include?(store_product.sku)
          store_product.update(stock: 0)
        end
      end
    end

    if !is_initial_sync && enabled_automate_promotions && !promotions.nil? && !promotions.empty? && !products_for_promotions.nil?
      products_for_promotions.each do |product|
        product_with_promotion = get_product_promotion(product, promotions)
        if api_client.is_green_haven_store?(@store_id)
          unless promotion_active?(product_with_promotion[:promotion])
            Rails.logger.info("Promotion Debug: Promotion inactive, removing promotion for product #{product[:ProductId]}")
            remove_promotion(product[:ProductId], store_products, store_products_promotions, product_with_promotion[:promotion][:Id])
            next
          end
        end
        if product_with_promotion[:price_discount] > 0 && !product_with_promotion[:promotion].nil?
          store_product_id = store_products.find { |store_product| store_product.sku == product_with_promotion[:product_id] }&.id
          products_ids_with_promotions_save << store_product_id
          save_promotions(product_with_promotion[:promotion], product, store_products, product_with_promotion[:price_discount])
        else
          remove_promotions(product[:ProductId], store_products, store_products_promotions)
        end
      end
    end

    if enabled_automate_promotions
      promotion_product_ids = store_products_promotions.pluck(:store_product_id)
      ids_to_delete = promotion_product_ids - products_ids_with_promotions_save
      Rails.logger.info("Promotion Debug: Total promotions to process: #{promotion_product_ids.size}")
      Rails.logger.info("Promotion Debug: Products with promotions to save: #{products_ids_with_promotions_save}")
      Rails.logger.info("Promotion Debug: Promotions to delete: #{ids_to_delete}")

      promotions_to_delete = StoreProductPromotion.where(store_product_id: ids_to_delete)
      # touch all the products that are going to be deleted
      products_to_touch = StoreProduct.where(id: promotions_to_delete.pluck(:store_product_id), store_id: @store_id)
      products_to_touch.each do |product|
        product.update!(has_promotion: false)
        product.touch
      end
      promotions_to_delete.destroy_all
    else
      ## Remove all promotions with promotion_id not null
      promotions_to_delete = StoreProductPromotion.where(store_product_id: store_products.map(&:id)).where.not(promotion_id: nil)
      promotions_to_delete.destroy_all
    end

    result[:sync] = store_sync if result[:errors].blank? && store_sync.save

    result
  end

  def product_promotions
    api_client.get_promotions(store)
  end

  def get_products(store_products)
    api_client.get_products(store_products, store)
  end

  private

  def inventory_products
    api_client.inventory_products(store)
  end

  def get_product_promotion(product, promotions)
    api_client.get_product_promotion(product, promotions)
  end

  def api_client
    @api_client ||= Covasoft::ApiClient.new(
      grant_type: store.grant_type,
      username: store.username,
      password_cova: store.password_cova,
      client_cova_id: store.client_cova_id,
      client_cova_secret: store.client_cova_secret,
      company_id: store.company_id,
      location_id_covasoft: store.location_id_covasoft
    )
  end

  def product_attribute(name, api_product_detail)
    if api_product_detail[:ProductSpecifications] && !api_product_detail[:ProductSpecifications].empty?
      if name == 'thc' || name == 'cbd'
        begin
          lab_result_value = api_product_detail[:ProductSpecifications].find { |e| e[:DisplayName].include? name.upcase }
          if lab_result_value
            return { name: name.upcase, value: "#{lab_result_value[:Value]}#{lab_result_value[:Unit]}" }
          else
            return {}
          end
        rescue StandardError => e
          Sentry.capture_exception(e)
          return {}
        end
      elsif name == 'strain'
        begin
          classification_value = api_product_detail[:ProductSpecifications].find { |e| e[:DisplayName] == "Strain" }
          if classification_value
            return { name: 'TYPE', value: classification_value[:Value] }
          else
            return {}
          end
        rescue StandardError => e
          Sentry.capture_exception(e)
          return {}
        end
      end
    end
  end

  def get_brand(api_product_detail)
    if api_product_detail[:ProductSpecifications] && !api_product_detail[:ProductSpecifications].empty?
      begin
        brand_value = api_product_detail[:ProductSpecifications].find { |e| e[:DisplayName] == "Brands" || e[:DisplayName] == "Brand"}
        if brand_value
          return brand_value[:Value]
        else
          ''
        end
      rescue StandardError => e
        Sentry.capture_exception(e)
        return ''
      end
    end
  end

  def get_weight(api_product_detail)
    if api_product_detail[:ProductSpecifications] && !api_product_detail[:ProductSpecifications].empty?
      begin
        weight_value = api_product_detail[:ProductSpecifications].find { |e| e[:DisplayName] == "Weight" }
        if weight_value
          if weight_value[:Unit] == "g"
            return weight_value[:Value].to_f
          elsif weight_value[:Unit] == "mg"
            return weight_value[:Value].to_i / 1000
          else
            return nil
          end
        end
      rescue StandardError => e
        Sentry.capture_exception(e)
        nil
      end
    end
    nil
  end

  def get_tags(api_product_detail)
    if api_product_detail[:ProductSpecifications] && !api_product_detail[:ProductSpecifications].empty?
      begin
        tags_value = api_product_detail[:ProductSpecifications].find { |e| e[:DisplayName] == "Tags" }
        if tags_value
          return tags_value[:Value].split ","
        else
          return []
        end
      rescue StandardError => e
        Sentry.capture_exception(e)
        return []
      end
    end
  end

  def sanitize_string(value)
    return value if value.blank?

    value.squish
  end

  def sanitize_html(value)
    return value if value.blank?

    html_sanitizer.sanitize(value).strip
  end

  def html_sanitizer
    html_sanitizer ||= Rails::Html::FullSanitizer.new
  end

  def safe_stock(product_stocks)
    product_stocks.sum { |product_stock| product_stock[:InStockQuantity] }
  end

  def save_promotions(promotion, product, store_products, discount_price = 0)
    # Find the product in the store
    product_found_by_db = store_products.find { |store_product| store_product.sku == product[:ProductId] && store_product.stock > 0}
    # Exit if the product is not found
    return unless product_found_by_db

    store_product_id = product_found_by_db.id
    promotion_exist = StoreProductPromotion.find_by(store_product_id: store_product_id)

    # Update or create existing promotion
    if promotion_exist
      Rails.logger.info("Promotion Debug: Updating existing promotion for product #{product[:ProductId]}")
      update_promotion(promotion, discount_price, promotion_exist, product_found_by_db)
    else
      begin
        # Only create the promotion if it does not exist
        store_promotion = StoreProductPromotion.new(
          promotion_name: promotion[:Name],
          promotion_id: promotion[:Id],
          store_product_id: store_product_id,
          promotion: "On Sale",
          discount_price: discount_price
        )
        product_found_by_db.has_promotion = true
        product_found_by_db.touch
        product_found_by_db.save!
        store_promotion.save!
      rescue StandardError => e
        Rails.logger.error("Promotion Debug: Failed to create promotion for product #{product[:ProductId]}: #{e.message}")
        Sentry.capture_exception(e)
      end
    end
  end

  def remove_promotion(product_id = nil, store_products = nil, store_product_promotions = nil, promotion_id = nil)
    return unless store_products && product_id && store_product_promotions && promotion_id

    Rails.logger.info("Promotion Debug: remove_promotion")
    Rails.logger.info("Promotion Debug: Attempting to remove promotion for product_id: #{product_id}")
    product = store_products.find { |product| product.sku == product_id }
    Rails.logger.info("Promotion Debug: Found product?: #{!product.nil?}")
    return unless product

    Rails.logger.info("Promotion Debug: Looking for promotion for store_product_id: #{product.id}")
    promotion = store_product_promotions.find { |promotion| promotion.store_product_id == product.id && promotion.promotion_id == promotion_id }
    Rails.logger.info("Promotion Debug: Found promotion?: #{!promotion.nil?}")
    return unless promotion

    has_other_promotions = store_product_promotions.find { |promo| promo.store_product_id == product.id && promo.promotion_id != promotion_id }
    doesnt_have_promotions = has_other_promotions.nil? || has_other_promotions.empty?

    promotion.destroy
    Rails.logger.info("Promotion Debug: Promotion removed for store_product_id: #{product.id}")

    if doesnt_have_promotions
      product.update!(has_promotion: false)
      Rails.logger.info("Promotion Debug: Product has no promotions, setting has_promotion to false for store_product_id: #{product.id}")
      return
    end
    product.touch
    Rails.logger.info("Promotion Debug: Touching product for store_product_id: #{product.id}")

  end

  def remove_promotions(product_id = nil, store_products = nil, store_product_promotions = nil)
    return unless store_products && product_id && store_product_promotions

    Rails.logger.info("Promotion Debug: remove_promotions")
    Rails.logger.info("Promotion Debug: Attempting to remove promotion for product_id: #{product_id}")
    product = store_products.find { |product| product.sku == product_id }
    Rails.logger.info("Promotion Debug: Found product?: #{!product.nil?}")
    return unless product
    
    Rails.logger.info("Promotion Debug: Looking for promotion for store_product_id: #{product.id}")
    promotion = store_product_promotions.find { |promotion| promotion.store_product_id == product.id }
    Rails.logger.info("Promotion Debug: Found promotion?: #{!promotion.nil?}")
    return unless promotion

    promotion.destroy

    product.update!(has_promotion: false)
    product.touch
  end

  def update_promotion(promotion, discount_price, promotion_exist, store_product)
    begin
      store_product.has_promotion = true
      store_product.touch
      Rails.logger.info("Promotion Debug: Updating promotion for product #{store_product.sku} with new discount: #{discount_price}")
      store_product.save!
      promotion_exist.update(promotion_name: promotion[:Name], promotion_id: promotion[:Id], discount_price: discount_price)
    rescue StandardError => e
      Rails.logger.error("Promotion Debug: Failed to update promotion for product #{store_product.sku}: #{e.message}")
      Sentry.capture_exception(e)
    end
  end

  def promotion_active?(promotion)
    return true if promotion.nil? # Keep backward compatibility
    return false unless promotion[:Status] == "Active"
    return true unless promotion[:Period] != nil && promotion[:Period][:Tag] != nil
    current_time = Time.current

    case promotion[:Period][:Tag]
    when "Definite"
      promotion[:Period][:DateRanges].any? do |range|
        start_time = Time.parse(range[:StartDate])
        end_time = Time.parse(range[:EndDate])
        current_time.between?(start_time, end_time)
      end
    when "Recurrent"
      pattern = promotion[:Period][:Pattern]
      time_schedule = promotion[:Period][:TimeSchedule]
      effective_range = promotion[:Period][:EffectiveDateRange]

      # Check if within effective date range
      start_date = Time.parse(effective_range[:StartDate])
      end_date = Time.parse(effective_range[:EndDate])
      return false unless current_time.between?(start_date, end_date)

      # Check if current day is in allowed days
      current_day = current_time.strftime("%A")
      return false unless pattern[:DaysOfTheWeek].include?(current_day)

      # Check if current time is within allowed hours
      current_time_of_day = current_time.strftime("%H:%M:%S")
      start_time = time_schedule[:StartTime]
      end_time = time_schedule[:EndTime]
      current_time_of_day.between?(start_time, end_time)
    else
      true # Keep backward compatibility for unknown period types
    end
  end
end
