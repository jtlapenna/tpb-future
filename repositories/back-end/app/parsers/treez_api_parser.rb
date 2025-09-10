require 'csv'

class TreezApiParser
  def initialize(store_id:)
    @store_id = store_id
  end

  def store
    @store ||= Store.find(@store_id)
  end

  def parse
    if store.api_version == 'v2.5'
      parsev25
    else
      parse_old
    end
  end

  def parsev25
    store_sync = StoreSync.new(store_id: @store_id)
    result = { errors: [], sync: nil }
    errors = []

    # take from the storeProduct table all the products id from the store
    store_products = StoreProduct.where(store_id: @store_id)

    db_promotions = StoreProductPromotion.where(store_product_id: store_products.pluck(:id))
    saved_promotions = []

    products_grouped_by_sku = store_products.group_by(&:sku)

    # Eliminate duplicated SKUs
    begin
      products_grouped_by_sku.each do |sku, products|
        next if products.size <= 1

        products_sorted = products.sort_by { |product| [product.stock, product.created_at] }

        products_to_remove = products_sorted[1..-1]
        product_to_keep = products_sorted.first

        # create a record in the duplicated_sku_deleted_logs table
        products_to_remove.each do |product|
          DuplicatedSkuDeletedLog.create(
              deleted_sku: product.sku,
              deleted_store_product_id: product.id,
              store_id: @store_id,
              store_product_id: product_to_keep.id
            )
        end
        products_to_remove.each(&:destroy)
      end
    rescue StandardError => e
      Sentry.capture_exception(e, level: :warning)
      puts "Error while removing duplicated SKUs: #{e.message}"
      Rails.logger.error("Error while removing duplicated SKUs: #{e.message}")
    end

    treez_product_types.each do |type|
      products(type_name: type).each_with_index do |api_prod, index|
        begin
          product_name = api_prod.dig(:product_configurable_fields, :name).to_s.strip
        rescue StandardError => e
          Sentry.capture_exception(e)
          Rails.logger.warn("Error while getting product name, using empty string: #{e.message}")
          product_name = ''
        end
        begin
          images = nil
          if api_prod[:e_commerce]
            commerce_primary_image = api_prod.dig(:e_commerce, :primary_image)
            images = {}
            if commerce_primary_image.present?
              images[:primary] = commerce_primary_image
              images[:thumb] = commerce_primary_image
            end
            images[:all_images] = api_prod.dig(:e_commerce, :all_images) || []
            begin
              hide_from_menu = api_prod.dig(:e_commerce, :hide_from_menu)
            rescue StandardError => e
              Sentry.capture_exception(e)
              Rails.logger.warn("Error while getting hide_from_menu, using false: #{e.message}")
              hide_from_menu = false
            end
          end
        rescue StandardError => e
          Sentry.capture_exception(e)
          Rails.logger.warn("Error while getting primary image or thumb image, using empty hash: #{e.message}")
          images = {}
        end
        begin
          inventory_type_medical = api_prod[:sellable_quantity_detail].map{|a| a[:inventory_type]}.include?("MEDICAL")
        rescue StandardError => e
          Sentry.capture_exception(e)
          Rails.logger.warn( "Error while getting inventory_type_medical, using empty array: #{e.message}")
          inventory_type_medical = []
        end

        begin
          # check if the enable_automate_promotions is true
          if store[:api_settings][:enable_automate_promotions] && !hide_from_menu
            #check if product is in the list of store_products list
            product = store_products.select{|a| a.sku == api_prod[:product_id]}
            if product.present?
              promotion = StoreProductPromotion.find_by(store_product_id: product[0].id)
            end

            if api_prod[:discounts].present? && api_prod[:sellable_quantity] > 0 && api_prod.dig(:pricing, :price_sell) && api_prod.dig(:pricing, :price_sell) > 0
              discounts = api_prod[:discounts]

              selected_discounts = discounts.select{|a| a[:discount_method] == "PERCENT" || a[:discount_method] == "DOLLAR"}

              # check if there are selected_discounts if there are then check if the product has a promotion
              if selected_discounts.present? && product.present?

                # check if each promotion is available
                selected_discounts.each do |discount|
                  # calculate the price with the discount and compare it with the price ind the api_prod
                  if discount[:discount_method] == "PERCENT"
                    discount_price = api_prod.dig(:pricing, :price_sell) - (api_prod.dig(:pricing, :price_sell) * discount[:discount_amount] / 100)

                    # only two decimal places
                    discount_price = discount_price.round(2)
                  else
                    discount_price = api_prod.dig(:pricing, :price_sell) - discount[:discount_amount]
                    # only two decimal places
                    discount_price = discount_price.round(2)
                  end

                  # if the dicount_price if different from the price in the api_prod then update the promotion
                  if api_prod.dig(:pricing, :discounted_price) != discount_price
                    #continue with the next loop
                    next
                  end

                  if discount[:discount_condition_detail]&.any? { |a| a[:discount_condition_type] != "Schedule" }
                    next
                  end

                  if promotion.present? &&  promotion.promotion_id == discount[:discount_id]
                    # promotion_is_available = promotion_available?(discount)
                    begin
                      promotion.update(
                        promotion_name: discount[:discount_title],
                        discount_price: discount_price < 0 ? 0.01 : discount_price
                      )
                    rescue StandardError => e
                      Sentry.capture_exception(e)
                      Rails.logger.error("Error while updating promotion_name and discount_price: #{e.message}, promotion_id: #{promotion.promotion_id}")
                    end
                    # touch the product to update the updated_at field
                    product[0].touch

                    #update the has_promotion field to true
                    begin
                      product[0].update(has_promotion: true)
                    rescue StandardError => e
                      Sentry.capture_exception(e)
                      Rails.logger.error( "Error while updating has_promotion to true: #{e.message}, product_id: #{product[0].id}")
                    end

                    # add the promotion to the list of saved_promotions
                    saved_promotions << promotion.id
                  else

                    if promotion.present?
                      begin
                        promotion.update(
                          promotion_id: discount[:discount_id],
                          promotion_name: discount[:discount_title],
                          promotion: 'On sale',
                          discount_price: discount_price < 0 ? 0.01 : discount_price
                        )
                      rescue StandardError => e
                        Sentry.capture_exception(e)
                        Rails.logger.error( "Error while updating promotion_id, promotion_name and discount_price: #{e.message}, promotion_id: #{promotion.promotion_id}")
                      end

                      # touch the product to update the updated_at field
                      product[0].touch

                      #update the has_promotion field to true
                      begin
                        product[0].update(has_promotion: true)
                      rescue StandardError => e
                        Sentry.capture_exception(e)
                        Rails.logger.error( "Error while updating has_promotion to true: #{e.message}, product_id: #{product[0].id}")
                      end

                      # add the promotion to the list of saved_promotions
                      saved_promotions << promotion.id
                    else
                      promotion = StoreProductPromotion.new(
                        store_product_id: product[0].id,
                        promotion_id: discount[:discount_id],
                        promotion_name: discount[:discount_title],
                        promotion: 'On sale',
                        discount_price: discount_price < 0 ? 0.01 : discount_price
                      )

                      if promotion.valid?
                        begin
                          promotion.save

                          # touch the product to update the updated_at field
                          product[0].touch

                          #update the has_promotion field to true
                          product[0].update(has_promotion: true)
                        rescue StandardError => e
                          Sentry.capture_exception(e)
                          Rails.logger.error( "Error while updating promotion and product has_promotion to true: #{e.message}, product_id: #{product[0].id}, promotion_id: #{promotion.promotion_id}")
                        end

                        saved_promotions << promotion.id

                      else
                        Rails.logger.error "Error on SKU #{api_prod[:product_id]}"
                        result[:errors] << { row: index + 1, messages: promotion.errors.messages }
                        Rails.logger.error "#{promotion.errors.messages}"
                      end
                    end
                  end
                end
              end
            else
              if promotion.present? && product.present?
                begin
                  promotion.destroy

                  product[0].update!(has_promotion: false)
                  product[0].touch
                rescue StandardError => e
                  Sentry.capture_exception(e)
                  Rails.logger.error( "Error while destroying promotion and product has_promotion to false: #{e.message}, product_id: #{product[0].id}, promotion_id: #{promotion.promotion_id}")
                end
              end
            end
          end

        rescue StandardError => e
          Sentry.capture_exception(e)
          Rails.logger.error("Error in a big function that does multiple things, product_id: #{api_prod[:product_id]}, error: #{e.message}")
          promotion = nil
        end

        item = StoreSyncItem.new(
          sku: api_prod[:product_id],
          name: product_name,
          description: api_prod.dig(:e_commerce, :product_description)&.scrub(''),
          size_name: product_name,
          category: api_prod[:category_type],
          stock: api_prod[:sellable_quantity],
          weight: api_prod.dig(:product_configurable_fields, :total_flower_weight_g) * 1000,
          brand: sanitize_string(api_prod.dig(:product_configurable_fields, :brand)),
          store_sync: store_sync,
          active: api_prod[:product_status] == 'ACTIVE' && !hide_from_menu,
          prices: [{ name: weight_label(api_prod.dig(:product_configurable_fields)), value: api_prod.dig(:pricing, :price_sell) != nil ? api_prod.dig(:pricing, :price_sell) : 0 }],
          images: images,
          tags: (api_prod.dig(:attributes, :effects) || []).map(&:downcase),
          attributes_values: generate_cannabis_attributes(api_prod),
          inventory_type_medical: inventory_type_medical
        )

        if item.valid?
          store_sync.store_sync_items << item
        else
          Rails.logger.error "Error on SKU #{api_prod[:product_id]} with errors: #{item.errors.messages}"
          result[:errors] << { row: index + 1, messages: item.errors.messages }
          Rails.logger.error "#{item.errors.messages}"
        end
      end
    end

    if !store[:api_settings][:enable_automate_promotions] 
      # destroy all the promotions that has promotion_name and  promotion_id filled
      promotions_to_delete = db_promotions.where.not(promotion_name: [nil, ''])

      # touch the products related to the deleted promotions
      promotions_to_delete.each do |promotion|
        # update the has_promotion field to false
        begin
          promotion.store_product.update!(has_promotion: false)
          promotion.store_product.touch
        rescue StandardError => e
          Sentry.capture_exception(e)
          Rails.logger.error("Error while updating has_promotion to false without enable_automated_promotions through promotion.store_product.update!: #{e.message}, promotion_id: #{promotion.promotion_id}")
          Rails.logger.error "Error on SKU #{promotion.store_product.sku}"
          Rails.logger.error "#{e.message}"
        end
      end

      promotions_to_delete.destroy_all
    else
      # delete all the promotions that are not in the saved_promotions
      promotions_to_delete = db_promotions.where.not(id: saved_promotions)

      # touch the products related to the deleted promotions
      promotions_to_delete.each do |promotion|
        # update the has_promotion field to false
        begin
          promotion.store_product.update!(has_promotion: false)
          promotion.store_product.touch
        rescue StandardError => e
          Sentry.capture_exception(e)
          Rails.logger.error("Error while updating has_promotion to false through promotion.store_product.update!: #{e.message}, promotion_id: #{promotion.promotion_id}")
          Rails.logger.error "Error on SKU #{promotion.store_product.sku}"
          Rails.logger.error "#{e.message}"
        end
      end

      promotions_to_delete.destroy_all
    end

    result[:sync] = store_sync if result[:errors].blank? && store_sync.save

    result
  end

  def parse_old
    store_sync = StoreSync.new(store_id: @store_id)
    result = { errors: [], sync: nil }
    errors = []

    treez_product_types.each do |type|
      products(type_name: type).each_with_index do |api_prod, index|
        product_name = api_prod[:product_name].to_s.strip

        items = (api_prod[:size_list] || []).map do |p_size|
          size_name = p_size[:product_size_name].to_s.strip
          if size_name.downcase == product_name.downcase &&
             p_size[:product_unit].present? && p_size[:size].present?
            size_name = "#{p_size[:size]} #{p_size[:product_unit]}"
          end

          images = nil
          if api_prod[:images]
            images = {}
            images[:primary] = api_prod[:images][:large_image] if api_prod[:images][:large_image]
            images[:thumb] = api_prod[:images][:cropped_image] if api_prod[:images][:cropped_image]
            if api_prod[:images][:cropped_image_url]
              images[:thumb] ||=
                api_prod[:images][:cropped_image_url]
            end
            images[:thumb] ||= images[:primary]
            images[:primary] ||= images[:thumb]
          end

          attributes = []
          if (prod_attributes = api_prod[:attributes])
            value = ''
            if prod_attributes[:thc_percentage].present?
              value = "#{api_prod[:attributes][:thc_percentage]}%"
            elsif prod_attributes[:total_mg_thc].present?
              value = "#{api_prod[:attributes][:total_mg_thc]} mg"
            end

            attributes.push(name: 'THC', value: value)

            value = ''

            if prod_attributes[:cbd_percentage].present?
              value = "#{api_prod[:attributes][:cbd_percentage]}%"
            elsif prod_attributes[:total_mg_cbd].present?
              value = "#{api_prod[:attributes][:total_mg_cbd]} mg"
            end

            attributes.push(name: 'CBD', value: value)
          end

          if (prod_classifications = api_prod[:classifications])
            classification = (prod_classifications || []).first
            value = classification || ''

            attributes.push(name: 'TYPE', value: value)
          end

          StoreSyncItem.new(
            sku: p_size[:size_id],
            name: product_name,
            description: api_prod[:description]&.scrub(''),
            size_name: size_name,
            category: p_size[:type] || api_prod[:type],
            stock: p_size[:live_inventory_quantity],
            brand: sanitize_string(api_prod[:brand]),
            store_sync: store_sync,
            active: api_prod[:active],
            prices: [{ name: size_name, value: p_size[:price_sell] != nil ? p_size[:price_sell] : 0 }],
            images: images,
            tags: (api_prod.dig(:attributes, :effects) || []).map(&:downcase),
            attributes_values: attributes
          )
        end

        items.each do |item|
          if item.valid?
            store_sync.store_sync_items << item
          else
            # Index is 0 based
            result[:errors] << { row: index + 1, messages: item.errors.messages }
          end
        end
      end
    end

    result[:sync] = store_sync if result[:errors].blank? && store_sync.save

    result
  end

  # get product is actually updating the product in the database.
  def get_product(sku)
    api_client.get_product(sku, @store_id)
  end

  def get_active_promotion(product_id)
    api_client.get_discount_type(product_id)
  end

  private

  def generate_cannabis_attributes(api_prod)
    attributes = []

    begin
      thc_values = get_thc(api_prod)
      if (thc_values != nil)
        attributes.push(name: 'THC', value: thc_values)
      elsif (total_mg_thc = api_prod[:product_configurable_fields][:total_mg_thc]).present?
        attributes.push(name: 'THC', value: total_mg_thc)
      end

      cbd_values = get_cbd(api_prod)
      if (cbd_values != nil)
        attributes.push(name: 'CBD', value: cbd_values)
      elsif (total_mg_cbd = api_prod[:product_configurable_fields][:total_mg_cbd]).present?
        attributes.push(name: 'CBD', value: total_mg_cbd)
      end

      if (classification = api_prod[:product_configurable_fields][:classification]).present?
        attributes.push(name: 'TYPE', value: classification)
      end

      if (size = api_prod[:product_configurable_fields][:size]).present?
        attributes.push(name: 'Size/Presentation', value: size)
      end

      attributes
    rescue StandardError => e
      Sentry.capture_exception(e)
      return attributes
    end
  end

  def products(type_name:)
    api_client.products(type_name: type_name)
  end

  def treez_product_types
    %w[all]
  end



  def get_thc(api_prod)
    if ((api_prod[:lab_results] == nil || api_prod[:lab_results] == []))
      return nil
    end

    thc_values = api_prod[:lab_results].select{ |result| result[:result_type] == 'THC' && result[:amount_type] == 'MG'};

    if (thc_values != nil && thc_values != [])
      return "#{thc_values[0][:amount][:minimum_value]} MG"
    end

    thc_percentage = api_prod[:lab_results].select{ |result| result[:result_type] == 'THC' && result[:amount_type] == 'PERCENTAGE'};

    if (thc_percentage != nil && thc_percentage != [])
      return "#{thc_percentage[0][:amount][:minimum_value]}%"
    end

    return nil
  end

  def get_cbd(api_prod)
    if ((api_prod[:lab_results] == nil || api_prod[:lab_results] == []))
      return nil
    end

    cbd_percentage = api_prod[:lab_results].select{ |result| result[:result_type] == 'CBD' && result[:amount_type] == 'PERCENTAGE'};

    if (cbd_percentage != nil && cbd_percentage != [])
      return "#{cbd_percentage[0][:amount][:minimum_value]}%"
    end

    cbd_values = api_prod[:lab_results].select{ |result| result[:result_type] == 'CBD' && result[:amount_type] == 'MG'};

    if (cbd_values != nil && cbd_values != [])
      return "#{cbd_values[0][:amount][:minimum_value]} MG"
    end

    return nil
  end

  def api_client
    @api_client ||= Treez::ApiClient.new(
      dispensary_name: store.dispensary_name,
      api_key: store.api_key,
      api_version: store.api_version,
      client_id: store.api_client_id,
      store_id: store.id
    )
  end

  def sanitize_string(value)
    return value if value.blank?

    value.squish
  end

  def weight_label(product_configurable_fields)

    uom_labels = {
    'GRAMS' => 'G',
    'MILLIGRAMS' => 'MG',
    'LITERS' => 'L',
    'FLUID OUNCES' => 'OZ',
    'MILLILITERS' => 'ML'
    }

    return '' unless product_configurable_fields[:amount] && product_configurable_fields[:amount] > 0

    uom = product_configurable_fields[:uom]
    return '' unless uom_labels.key?(uom)

    amount = product_configurable_fields[:amount]
    rounded_amount_split = amount.round(1).to_s.split('.')
    if rounded_amount_split[1] == '0'
      rounded_amount = rounded_amount_split[0]
    else
      rounded_amount = product_configurable_fields[:amount].round(1)
    end

    "#{rounded_amount}#{uom_labels[uom]}"
  end

  def promotion_available?(promotion)
    if !promotion[:discount_condition_detail].present?
      return true
    end

    promotion[:discount_condition_detail].each do |condition|
      if condition[:discount_condition_type] == "Schedule"
        value = condition[:discount_condition_value]

        if value.include?("Does not repeat")  # check the promotion date
          return promotion_date_available?(value)
        end

        # Check if the promotion never ends
        if value.include?("Ends never")
          return promotion_date_available?(value)
        end

        # Check if the promotion repeats daily
        if value.include?("Daily")
          return promotion_date_available?(value)
        end

        # Check if the promotion repeats weekly on Tuesday
        if value.include?("Weekly on Tuesday") && Date.today.wday == 2
        return promotion_date_available?(value)
        end

        # Check if the promotion repeats monthly on fifth Tuesday
        if value.include?("Monthly on fifth Tuesday") && Date.today.wday == 2 && (Date.today.day / 7) == 5
          return promotion_date_available?(value)
        end

        # Check if the promotion repeats annually on October 31st
        if value.include?("Annually on October 31st") && Date.today.month == 10 && Date.today.day == 31
          return promotion_date_available?(value)
        end

        # Check if the promotion repeats every weekday
        if value.include?("Every Weekday (Monday to Friday)") && Date.today.wday >= 1 && Date.today.wday <= 5
          return promotion_date_available?(value)
        end
      else
        return false
      end
    end

    false
  end

    # check promotion frequency and time
  def promotion_date_available?(condition)
    # Check if the promotion starts on a specific date and if we are past that date and check the ending at or ending on date
    if condition.include?("Starting on") && Date.today.strftime("%Y-%m-%d") >= condition.split("Starting on ")[1].split(" ")[0]
      # check the ending at or ending on date check if if the promotios still available

      if condition.include?("ending on") && Date.today <= Date.parse(condition.split("ending on ")[1].split(" ")[0])
        return true
      end
      if condition.include?("ending at") && Time.now.strftime("%H:%M") <= condition.split("ending at ")[1].split(" ")[0]
        return true
      end
    end

    # Check if the promotion starts at a specific time and if we are past that time
    if condition.include?("Starting at") && Time.now.strftime("%H:%M") >= condition.split("Starting at ")[1].split(" ")[0]
      # check the ending at or ending on date check if if the promotios still available
      if condition.include?("ending on") && Date.today.strftime("%Y-%m-%d") <= condition.split("ending on ")[1].split(" ")[0]
        return true
      end
      if condition.include?("ending at") && Time.now.strftime("%H:%M") <= condition.split("ending at ")[1].split(" ")[0]
        return true
      end
    end

    return false
  end

end
