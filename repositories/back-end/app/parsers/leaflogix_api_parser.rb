require 'csv'

class LeaflogixApiParser
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
    products = product_detail

    # take from the storeProduct table all the products id from the store
    # get all the promotions from the store based on the store products id and group them by promotion_id

    store_products = StoreProduct.where(store_id: @store_id)

    if store[:api_settings][:enable_automate_promotions]
      promotion_list = product_promotions
      store_location = location
      store_products_ids = store_products.pluck(:id)
      store_promotions = StoreProductPromotion.where(store_product_id: store_products_ids)

      # get the store_product_id from the saved_promotions
      saved_promotions = store_promotions.group_by { |promotion| promotion.promotion_id }

      store_product_promotion_saved = []
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

  inventory.each_with_index do |inventory_entry, index|
      product = products.select { |product| product[:productId] === inventory_entry[:productId] }.first || {}
      product_unit_type = products.select { |product| product[:productId] === inventory_entry[:productId] }.first[:unitType] || nil
      if store[:api_settings][:enable_automate_promotions] && promotion_list.length > 0 && inventory_entry[:quantityAvailable] > 0
        # Remove promotions if product not have promotion_id
        store_products = StoreProduct.where(sku: inventory_entry[:productId], store_id: @store_id)
        promotions = StoreProductPromotion.where(store_product_id: store_products.pluck(:id), promotion_id: nil)
        if promotions.exists?
          store_products.each do |product|
            begin
              product.update!(has_promotion: false)
              product.touch
            rescue StandardError => e
              Sentry.capture_exception(e)
            end
          end

          promotions.destroy_all
        end
        existing_promotion_ids = saved_promotions.keys
        promotion_ids_in_iteration = promotion_list.map { |promotion| promotion["id"].to_i }
        promotion_ids_to_remove = existing_promotion_ids.map(&:to_i) - promotion_ids_in_iteration.map(&:to_i)
        promotion_list.each do |promotion|
          if promotion["reward"]["restrictions"].empty?
            promotion_ids_to_remove << promotion["id"]
          end
        end
        if promotion_ids_to_remove.any?
          promotions_to_remove = StoreProductPromotion.where(promotion_id: promotion_ids_to_remove)

          products_to_touch = StoreProduct.where(id: promotions_to_remove.pluck(:store_product_id), store_id: @store_id)

          products_to_touch.each do |product|
            begin
              product.update!(has_promotion: false)
              product.touch
            rescue StandardError => e
              Sentry.capture_exception(e)
            end
          end

          promotions_to_remove.destroy_all
        end

        product_grams = products.select { |product| product[:productId] === inventory_entry[:productId] }.first[:productGrams] || nil

        if product_grams != nil
          formatted_number = sprintf("%.1f", product_grams).to_f
        end

        # get the promotions for the product 
        product_promotions_list = promotion_list.select do |promotion|
          product_is_exclusion = promotion.dig("reward", "restrictions", "Product", "isExclusion")
          category_is_exclusion = promotion.dig("reward", "restrictions", "Category", "isExclusion")
          brand_is_exclusion = promotion.dig("reward", "restrictions", "Brand", "isExclusion")
          weight_is_exclusion = promotion.dig("reward", "restrictions", "Weight", "isExclusion")

          product_match = product_is_exclusion ? !promotion.dig("reward", "restrictions", "Product", "restrictionIds")&.include?(inventory_entry[:productId]) : promotion.dig("reward", "restrictions", "Product", "restrictionIds")&.include?(inventory_entry[:productId])
          category_match = category_is_exclusion ? !promotion.dig("reward", "restrictions", "Category", "restrictionIds")&.include?(inventory_entry[:categoryId]) : promotion.dig("reward", "restrictions", "Category", "restrictionIds")&.include?(inventory_entry[:categoryId])
          brand_match = brand_is_exclusion ? !promotion.dig("reward", "restrictions", "Brand", "restrictionIds")&.include?(inventory_entry[:brandId]) : promotion.dig("reward", "restrictions", "Brand", "restrictionIds")&.include?(inventory_entry[:brandId])
          weight_match = weight_is_exclusion ? !promotion.dig("reward", "restrictions", "Weight", "restrictionIds")&.include?(formatted_number) : promotion.dig("reward", "restrictions", "Weight", "restrictionIds")&.include?(formatted_number)

          product_match || category_match || brand_match || weight_match
        end

        product_promotions_available_list = product_promotions_list.select do |promotion|
          restrictions = promotion["reward"]["restrictions"]
          category_restriction = restrictions["Category"]
          category_exclusion = category_restriction.present? ? category_restriction["isExclusion"] : false
          brand_restriction = restrictions["Brand"]
          brand_exclusion = brand_restriction.present? ? brand_restriction["isExclusion"] : false
          product_restriction = restrictions["Product"]
          product_exclusion = product_restriction.present? ? product_restriction["isExclusion"] : false
          weight_restriction = restrictions["Weight"]
          weight_exclusion = weight_restriction.present? ? weight_restriction["isExclusion"] : false

          next if restrictions.keys - ["Category", "Brand", "Product", "Weight"] != []

          category_match = if category_restriction.present?
                             category_exclusion ? !category_restriction["restrictionIds"].include?(inventory_entry[:categoryId]) : category_restriction["restrictionIds"].include?(inventory_entry[:categoryId])
                           else
                             false
                           end
          brand_match = if brand_restriction.present?
                          brand_exclusion ? !brand_restriction["restrictionIds"].include?(inventory_entry[:brandId]) : brand_restriction["restrictionIds"].include?(inventory_entry[:brandId])
                        else
                          false
                        end
          product_match = if product_restriction.present?
                            product_exclusion ? !product_restriction["restrictionIds"].include?(inventory_entry[:productId]) : product_restriction["restrictionIds"].include?(inventory_entry[:productId])
                          else
                            false
                          end
          weight_match = if weight_restriction.present?
                           weight_exclusion ? !weight_restriction["restrictionIds"].include?(formatted_number) : weight_restriction["restrictionIds"].include?(formatted_number)
                         else
                           false
                         end

          if category_match && brand_match && product_match && weight_match
            promotion
          elsif category_match && brand_match && product_match && !weight_restriction
            promotion
          elsif category_match && !brand_restriction && product_match && weight_match
            promotion
          elsif category_match && brand_match && !product_restriction && weight_match
            promotion
          elsif category_match && brand_match && !product_restriction && !weight_restriction
            promotion
          elsif category_match && !brand_restriction && product_match && !weight_restriction
            promotion
          elsif category_match && !brand_restriction && !product_restriction && weight_match
            promotion
          elsif category_match && !brand_restriction && !product_restriction && !weight_restriction
            promotion
          elsif brand_match && product_match && weight_match && !category_restriction
            promotion
          elsif brand_match && product_match && !category_restriction && !weight_restriction
            promotion
          elsif brand_match && weight_match && !category_restriction && !product_restriction
            promotion
          elsif brand_match && !product_restriction && !weight_restriction && !category_restriction
            promotion
          elsif product_match && weight_match && !category_restriction && !brand_restriction
            promotion
          elsif product_match && !weight_restriction && !category_restriction && !brand_restriction
            promotion
          elsif weight_match && !product_restriction && !category_restriction && !brand_restriction
            promotion
          end
        end

        if product_promotions_available_list.length > 0
          active_product_promotion = get_active_promotion(product_promotions_available_list, inventory_entry, store_location, product_unit_type)

          if active_product_promotion
            # save the product id in the store_product_promotion_saved 
            database_product_id = StoreProduct.where(sku: inventory_entry[:productId], store_id: @store_id).pluck(:id)
            store_product_promotion_saved << database_product_id[0]

            save_promotions(active_product_promotion, inventory_entry)
          else
            remove_promotions(inventory_entry[:productId])
          end
        else
          remove_promotions(inventory_entry[:productId])
        end
      else
        remove_promotions
      end

      Rails.logger.debug("inventory full #{inventory_entry}")
      Rails.logger.debug("product full #{product}")

      product_name = sanitize_string(inventory_entry[:productName])

      size_name = product_name
      images = {}
      if product[:imageUrl]
        images[:primary] = product[:imageUrl]
        images[:thumb] = images[:primary]
      end

      attributes = %w[thc cbd thca].map { |attr_name| product_attribute(product, attr_name, inventory_entry) }.compact

      Rails.logger.debug("product attributes #{attributes}")

      if product[:strainType].present?        
        attributes.push(name: 'TYPE', value: product[:strainType])
      end

      inventory_entry_category = store[:api_settings][:use_master_category] && product[:masterCategory] != '' ? product[:masterCategory] : product[:category]

      product_weight = inventory_entry[:unitWeight] != nil ? (inventory_entry[:unitWeightUnit] == 'g' ? inventory_entry[:unitWeight].to_f * 1000 : inventory_entry[:unitWeight].to_f) : 0

      item = StoreSyncItem.new(
        sku: inventory_entry[:productId],
        name: product_name,
        description: sanitize_html(inventory_entry[:description]),
        size_name: product_name,
        category: inventory_entry_category,
        stock: inventory_entry[:quantityAvailable] || 0,
        brand: sanitize_string(product[:brandName]),
        store_sync: store_sync,
        active: product[:isActive] || false,
        prices: [{ name: inventory_entry[:size], value: inventory_entry[:unitPrice].to_f }],
        images: images,
        weight: product_weight,
        tags: product[:tags].present? ? product[:tags].map{|tag| tag[:tagName] } : inventory_entry[:tags].present? ? inventory_entry[:tags].map{|tag| tag[:tagName] } : [],
        attributes_values: store[:api_settings][:use_total_thc] ? (thca_potency(attributes, inventory_entry_category)) : attributes,
        is_medical_only: inventory_entry[:medicalOnly],
      )

      if item.valid?
        store_sync.store_sync_items << item
      else
        # Index is 0 based
        result[:errors] << { row: index + 1, messages: item.errors.messages }
      end
    end

    if store[:api_settings][:enable_automate_promotions]
      promotion_product_ids = store_promotions.pluck(:store_product_id)
      ids_to_delete = promotion_product_ids - store_product_promotion_saved
      promotions_to_delete = StoreProductPromotion.where(store_product_id: ids_to_delete)
      ## touch all the products that are going to be deleted
      products_to_touch = StoreProduct.where(id: promotions_to_delete.pluck(:store_product_id), store_id: @store_id)
      products_to_touch.each do |product|
        begin
          product.update!(has_promotion: false)
          product.touch
        rescue StandardError => e
          Sentry.capture_exception(e)
        end
      end
      promotions_to_delete.destroy_all
    end

    result[:sync] = store_sync if result[:errors].blank? && store_sync.save

    result
  end

  private

  def products
    @products ||= begin
      api_client.products.map do |product|
        key = product[:productId]
        value = product
        [key, value]
      end.to_h
    end
  end

  def inventory
    @inventory ||= api_client.inventory
  end

  def product_detail
    @products ||= api_client.products
  end

  def api_client
    @api_client ||= Leaflogix::ApiClient.new(store.leaflogix_api_config)
  end

  def product_promotions
    @product_promotions ||= api_client.get_promotions
  end

  def location
    @location ||= api_client.get_location
  end

  def sanitize_string(value)
    return value if value.blank?

    value.squish
  end

  def sanitize_html(value)
    return value if value.blank?

    html_sanitizer.sanitize(value).strip
  end

  def product_attribute(prod, name, inventory)
    Rails.logger.debug("inventory labResultValue #{inventory[:labResults]}")
    if (inventory[:labResults] != nil)
      begin
        labResultValue = inventory[:labResults].select{|e| e[:labTest] == name.upcase }
        Rails.logger.debug("extracted labResultValue #{labResultValue}")
        if (labResultValue != nil && labResultValue != [])
          if (labResultValue[0][:labResultUnit] == 'Percentage')
            labResultUnit = '%'
          elsif (labResultValue[0][:labResultUnit] == 'Milligrams')
            labResultUnit = 'mg'
          else
            labResultUnit = ''
          end
          labResultName = "#{labResultValue[0][:value]}#{labResultUnit}"
          return { name: name.upcase, value: labResultName }
        end

        content_key = "#{name}Content".to_sym
        content_unit_key = "#{name}ContentUnit".to_sym

        return unless prod[content_key].present? && prod[content_unit_key].present?

        value = "#{prod[content_key]}#{prod[content_unit_key]}"

        { name: name.upcase, value: value }
      rescue StandardError => e
        Sentry.capture_exception(e)
        return {}
      end
    end

  end

  def thca_potency(value, category)
    begin
      thca_obj = value.find { |obj| obj[:name] == "THCA" }
      thca_value = thca_obj && thca_obj[:value].include?("%") ? thca_obj[:value].to_f : 0.0
    
      thc_obj = value.find { |obj| obj[:name] == "THC" }
      thc_value = thc_obj && thc_obj[:value].include?("%") ? thc_obj[:value].to_f : 0.0
    
      modified_array = value.map do |obj|
        if (obj[:name] == "THC" && obj[:value].include?("%") && ["flower", "flowers", "pre-rolls", "pre-roll", "prerolls", "preroll", "concentrate", "concentrates"].include?(category.downcase))
          new_thc_value = (thca_value * 0.877) + thc_value
          obj[:value] = "#{new_thc_value.round(1)}%"
        end
        obj
      end
    
      return modified_array
    rescue StandardError => e
      Sentry.capture_exception(e)
      return []
    end
  end

  def html_sanitizer
    html_sanitizer ||= Rails::Html::FullSanitizer.new
  end

  def save_promotions(promotion, product)
    # Find the product in the shop
    store_product = StoreProduct.find_by(sku: product[:productId], store_id: @store_id)
    # Exit if the product is not found
    return unless store_product

    store_product_id = store_product.id
    promotion_exist = StoreProductPromotion.find_by(store_product_id: store_product_id)

    # Update or create existing promotion
    if promotion_exist
      update_promotion(promotion, product, promotion_exist, store_product)
    else
      begin
        # Only create the promotion if it does not exist
        store_promotion = StoreProductPromotion.new(
          promotion_name: promotion["discountDescription"],
          promotion_id: promotion["id"],
          store_product_id: store_product_id,
          promotion: promotion["isSpecialOffer"] ? "Special Offer" : "On Sale",
          discount_price: promotion["isSpecialOffer"] ? 0 : product[:unitPrice] - promotion["discountValue"],
          discount_type: promotion["reward"]["calculationMethod"]
        )
        store_product.has_promotion = true
        store_product.touch
        store_product.save!
        store_promotion.save!
      rescue StandardError => e
        Sentry.capture_exception(e)
      end
    end
  end

  def remove_promotions(product_id = nil)
    if product_id.nil?
      promotions = StoreProductPromotion.joins(:store_product).where(store_products: { store_id: @store_id }).where.not(promotion_id: nil)
    else
      promotions = StoreProductPromotion.where(store_product_id: StoreProduct.where(sku: product_id, store_id: @store_id).pluck(:id))
    end

    if promotions.exists?
      promotions.each do |promotion|
        begin
          promotion.store_product.update(has_promotion: false)
          promotion.store_product.touch
        rescue StandardError => e
          Sentry.capture_exception(e)
        end
      end
      promotions.destroy_all
    end
  end

  def get_active_promotion(promotion_list, product, store_location, product_unit_type)
    active_promotion_with_highest_discount = nil
    previous_discount = 0
    number_of_items_promotion = nil

    promotion_list.each do |promotion|
      if promotion["isActive"]
        start_date = promotion["validDateFrom"] ? Date.parse(promotion["validDateFrom"]) : nil
        end_date = promotion["validDateTo"] ? Date.parse(promotion["validDateTo"]) : nil
        start_time = promotion["startTime"]
        end_time = promotion["endTime"]
        current_date = Date.today
        current_day = Date.today.strftime("%A").downcase
        days_promotion = {
          "monday" => promotion["monday"],
          "tuesday" => promotion["tuesday"],
          "wednesday" => promotion["wednesday"],
          "thursday" => promotion["thursday"],
          "friday" => promotion["friday"],
          "saturday" => promotion["saturday"],
          "sunday" => promotion["sunday"]
        }

        if valid_promotion?(start_date, end_date, current_date, promotion, days_promotion, current_day, store_location, start_time, end_time)
          price_discount = calculate_discount(promotion, product)

          if promotion["reward"]["thresholdType"] && promotion["reward"]["thresholdType"] === "NUMBER_OF_ITEMS" && product_unit_type && product_unit_type === "Qty"
            number_of_items_promotion = promotion
          elsif price_discount && (active_promotion_with_highest_discount.nil? || price_discount > previous_discount) && product[:unitPrice] > price_discount && promotion["reward"]["thresholdType"].nil?
            active_promotion_with_highest_discount = promotion
            previous_discount = price_discount
          end
        end
      end
    end

    if number_of_items_promotion
      number_of_items_promotion["isSpecialOffer"] = true
      return number_of_items_promotion
    elsif active_promotion_with_highest_discount && previous_discount > 0
      active_promotion_with_highest_discount["discountValue"] = previous_discount
      active_promotion_with_highest_discount["isSpecialOffer"] = false
      return active_promotion_with_highest_discount
    end

    nil
  end


  def valid_promotion?(start_date, end_date, current_date, promotion, days_promotion, current_day, store_location, start_time, end_time)
    start_date && end_date && start_time.nil? && end_time.nil? && current_date >= start_date && current_date <= end_date &&
    (promotion["locationRestrictions"].length == 0 || promotion["locationRestrictions"].include?(store_location["locationId"])) &&
    (!days_promotion.values.any? { |value| value == true } || (days_promotion.key?(current_day) && days_promotion[current_day]))
  end

  def calculate_discount(promotion, product)
    calculation_methods = {
      "PERCENT_OFF" => -> { product[:unitPrice].to_f * promotion.dig("reward", "discountValue")},
      "PRICE_TO_AMOUNT_TOTAL" => -> { promotion.dig("reward", "discountValue") },
      "AMOUNT_OFF" => -> { promotion.dig("reward", "discountValue") },
      "PRICE_TO_AMOUNT" => -> { promotion.dig("reward", "discountValue") },
      "AMOUNT_OFF_TOTAL" => -> { promotion.dig("reward", "discountValue") }
    }

    method = promotion.dig("reward", "calculationMethod")
    if calculation_methods.key?(method)
      price_discount = calculation_methods[method].call

      price_discount
    end
  end

  def update_promotion(promotion, product, promotion_exist, store_product)
    begin
      store_product.has_promotion = true
      store_product.touch
      store_product.save!
      promotion_exist.update(promotion_name: promotion["discountDescription"], promotion_id: promotion["id"], discount_price: promotion["isSpecialOffer"] ? 0 : product[:unitPrice] - promotion["discountValue"], promotion: promotion["isSpecialOffer"] ? "Special Offer" : "On Sale", discount_type: promotion["reward"]["calculationMethod"])
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end
end
