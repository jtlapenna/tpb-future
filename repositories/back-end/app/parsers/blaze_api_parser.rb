require 'csv'
require 'date'

class BlazeApiParser

  def initialize(store_id:)
    @store_id = store_id
  end

  def store
    @store ||= Store.find(@store_id)
  end

  def api_client
    @api_client ||= Blaze::ApiClient.new(
      authorization_blaze: store.authorization_blaze,
      partner_key_blaze: store.partner_key_blaze
    )
  end

  def inventory_products
    api_client.inventory_products
  end

  # def products_promotions
  #   api_client.get_promotions
  # end

  def parse
    store_sync = StoreSync.new(store_id: @store_id)
    result = { errors: [], sync: nil }
    errors = []
    inventory_list = []

    store_products = StoreProduct.where(store_id: @store_id)

    if store[:api_settings][:inventory_list]
      inventory_list = store[:api_settings][:inventory_list].split(',')
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

    inventory_products[:values].each_with_index do |api_product, index|
      # products_promotions.each do |promotion|
      #   start_date = promotion["startDate"] ? Time.at(promotion["startDate"] / 1000) : nil
      #   end_date = promotion["endDate"] ? Time.at(promotion["endDate"] / 1000) : nil
      #
      #   if start_date && end_date && start_date <= Time.now && end_date >= Time.now
      #     promotions(promotion, api_product)
      #   end
      # end

      next if (inventory_list.present? && !api_product[:quantities].any? { |quantity| inventory_list.include?(quantity[:inventoryId]) })

      quantity = get_quantity(api_product[:quantities], inventory_list)

      begin
        product_name = api_product.dig(:name).to_s.strip
      rescue StandardError => e
        Sentry.capture_exception(e)
        product_name = ''
      end

      begin
        images = {}
        if api_product[:assets] && api_product[:assets] != nil && api_product[:assets] != []
          images[:primary] = api_product[:assets][0][:publicURL]
          images[:thumb] = api_product[:assets][0][:publicURL]
        else
          images[:primary] = api_product[:category][:photo][:publicURL]
          images[:thumb] = api_product[:category][:photo][:publicURL]
        end
      rescue StandardError => e
        Sentry.capture_exception(e)
        images = {}
      end

      item = StoreSyncItem.new(
        sku: api_product[:id],
        name: product_name,
        description: api_product[:description],
        weight: get_weight_value(api_product),
        category: api_product[:category] && api_product[:category] != nil && api_product[:category][:name] != [] ? api_product[:category][:name] : {},
        stock: quantity,
        brand: api_product[:brand] && api_product[:brand] != nil && api_product[:brand][:name] != [] ? api_product[:brand][:name] : {},
        store_sync: store_sync,
        active: api_product[:active],
        prices: [{ name: get_weight_name(api_product), value: get_prices(api_product) }],
        images: images,
        tags: api_product[:tags],
        attributes_values: generate_cannabis_attributes(api_product)
      )

      if item.valid?
        store_sync.store_sync_items << item
      else
        # Index is 0 based
        result[:errors] << { row: index + 1, messages: item.errors.messages }
      end
    end

    result[:sync] = store_sync if result[:errors].blank? && store_sync.save

    result

  end

  def generate_cannabis_attributes(api_product)
    begin
      attributes = []

      thc_values = get_thc(api_product)
      if (thc_values != nil)
        attributes.push(name: 'THC', value: thc_values)
      elsif (total_mg_thc = api_product[:potencyAmount][:thc]).present?
        attributes.push(name: 'THC', value: total_mg_thc)
      end

      cbd_values = get_cbd(api_product)
      if (cbd_values != nil)
        attributes.push(name: 'CBD', value: cbd_values)
      elsif (total_mg_cbd = api_product[:potencyAmount][:cbd]).present?
        attributes.push(name: 'CBD', value: total_mg_cbd)
      end

      if (classification = api_product[:flowerType]).present?
        attributes.push(name: 'TYPE', value: classification)
      end

      if (strain_type = api_product[:flowerType]).present?
        attributes.push(name: 'STRAIN TYPE', value: strain_type)
      end

      if (sub_category = api_product[:cannabisType]).present?
        attributes.push(name: 'SUB CATEGORY', value: sub_category)
      end

      attributes
    rescue StandardError => e
      Sentry.capture_exception(e)
      return attributes = []
    end
  end

  def promotions(promotion, api_product)
    if promotion["target"]["productIds"].length > 0
      promotion["target"]["productIds"].each do |product_id|
        promotion_exist = nil
        if product_id == api_product[:id]
          store_product = StoreProduct.find_by(sku: api_product[:id])
          if store_product
            store_product_id = store_product.id
            promotion_exist = StoreProductPromotion.find_by(promotion_id: promotion["id"], store_product_id: store_product_id)
          end

          if promotion_exist
            promotion_exist.update(promotion_name: promotion["name"])
          elsif promotion_exist.nil? && store_product
            store_promotion = StoreProductPromotion.new
            store_promotion.promotion_name = promotion["name"]
            store_promotion.promotion_id = promotion["id"]
            store_promotion.store_product_id = store_product_id
            store_promotion.promotion = "On Sale"
            store_promotion.save!
          end
        end
      end
    end

    if promotion["target"]["categoryIds"].length > 0
      promotion["target"]["categoryIds"].each do |category_id|
        promotion_exist = nil
        if category_id == api_product[:categoryId]
          store_product = StoreProduct.find_by(sku: api_product[:id])
          if store_product
            store_product_id = store_product.id
            promotion_exist = StoreProductPromotion.find_by(promotion_id: promotion["id"], store_product_id: store_product_id)
          end

          if promotion_exist
            promotion_exist.update(promotion_name: promotion["name"])
          elsif promotion_exist.nil? && store_product
            store_promotion = StoreProductPromotion.new
            store_promotion.promotion_name = promotion["name"]
            store_promotion.promotion_id = promotion["id"]
            store_promotion.store_product_id = store_product_id
            store_promotion.promotion = "On Sale"
            store_promotion.save!
          end
        end
      end
    end

    if promotion["target"]["brandIds"].length > 0
      promotion["target"]["brandIds"].each do |brand_id|
        promotion_exist = nil
        if brand_id == api_product[:brandId]
          store_product = StoreProduct.find_by(sku: api_product[:id])
          if store_product
            store_product_id = store_product.id
            promotion_exist = StoreProductPromotion.find_by(promotion_id: promotion["id"], store_product_id: store_product_id)
          end

          if promotion_exist
            promotion_exist.update(promotion_name: promotion["name"])
          elsif promotion_exist.nil? && store_product
            store_promotion = StoreProductPromotion.new
            store_promotion.promotion_name = promotion["name"]
            store_promotion.promotion_id = promotion["id"]
            store_promotion.store_product_id = store_product_id
            store_promotion.promotion = "On Sale"
            store_promotion.save!
          end
        end
      end
    end

    if promotion["target"]["vendorIds"].length > 0
      promotion["target"]["vendorIds"].each do |vendorId|
        promotion_exist = nil
        if vendorId == api_product[:vendorId]
          store_product = StoreProduct.find_by(sku: api_product[:id])
          if store_product
            store_product_id = store_product.id
            promotion_exist = StoreProductPromotion.find_by(promotion_id: promotion["id"], store_product_id: store_product_id)
          end

          if promotion_exist
            promotion_exist.update(promotion_name: promotion["name"])
          elsif promotion_exist.nil? && store_product
            store_promotion = StoreProductPromotion.new
            store_promotion.promotion_name = promotion["name"]
            store_promotion.promotion_id = promotion["id"]
            store_promotion.store_product_id = store_product_id
            store_promotion.promotion = "On Sale"
            store_promotion.save!
          end
        end
      end
    end
  end

  def get_thc(api_product)
    if ((api_product[:potencyAmount] == nil || api_product[:potencyAmount] == []))
      return nil
    end

    thc_values_mg = api_product[:potencyAmount][:thc]
    is_edibles_category = api_product[:category][:name] == 'Edibles'

    if (is_edibles_category && thc_values_mg > 0.0)
      return "#{thc_values_mg} MG"
    end

    thc_percentage = api_product[:thc]

    if (thc_percentage > 0.0)
      return "#{thc_percentage}%"
    end

    if (thc_values_mg)
      return "#{thc_values_mg} MG"
    end


    return nil
  end

  def get_cbd(api_product)
    if ((api_product[:potencyAmount] == nil || api_product[:potencyAmount] == []))
      return nil
    end

    cbd_percentage = api_product[:cbd]

    if (cbd_percentage)
      return "#{cbd_percentage}%"
    end

    cbd_values_thc = api_product[:potencyAmount][:cbd]

    if (cbd_values_thc)
      return "#{cbd_values_thc} MG"
    end

    return nil
  end

  def get_prices(api_product)
    begin
      if (api_product[:priceBreaks] != [])
        if (api_product[:priceBreaks][0][:salePrice] && api_product[:priceBreaks][0][:salePrice] > 0)
          return api_product[:priceBreaks][0][:salePrice]
        elsif (api_product[:unitPrice] > 0)
          return api_product[:unitPrice]
        else
          return 0.0
        end
      end

      if (api_product[:priceRanges] != [])
        if api_product[:priceRanges][0][:salePrice] && api_product[:priceRanges][0][:salePrice] > 0
          return api_product[:priceRanges][0][:salePrice]
        elsif (api_product[:priceRanges][0][:price] && api_product[:priceRanges][0][:price] > 0)
          return api_product[:priceRanges][0][:price]
        else
          return 0.0
        end
      end

      return 0.0
    rescue StandardError => e
      Sentry.capture_exception(e)
      return 0.0
    end
  end

  def get_weight_value(api_product)
    if (api_product[:weightPerUnit] === 'CUSTOM_GRAMS' && api_product[:weightPerUnit] != nil)
      return api_product[:customWeight]
    else
      return 0
    end
  end

  def get_weight_name(api_product)
    begin
      if (api_product[:weightPerUnit] != nil)
        if (api_product[:weightPerUnit] == 'EACH')
          return 'Each'
        elsif (api_product[:weightPerUnit] == 'HALF_GRAM')
          return 'Half Gram'
        elsif (api_product[:weightPerUnit] == 'FULL_GRAM')
          return 'Gram'
        elsif (api_product[:weightPerUnit] == 'EIGHTH')
          return 'Eighth'
        elsif (api_product[:weightPerUnit] === 'CUSTOM_GRAMS')
          if (api_product[:customGramType] === 'GRAM')
            return "#{api_product[:customWeight]}g"
          else
            return "#{api_product[:customWeight]}ml"
          end
        end
      end

      return ''
    rescue StandardError => e
      Sentry.capture_exception(e)
      return ''
    end
  end

  def get_quantity(quantities, inventory_list)
    if inventory_list.present?
      inventory_list.each do |inventory_id|
        quantity = quantities.find { |quantity| quantity[:inventoryId] == inventory_id }
        
        return quantity[:quantity] if quantity.present? && quantity[:quantity].to_i > 0
      end

      return 0
    else
      quantities && quantities != nil && quantities != [] ? quantities[0][:quantity] : 0
    end
  end
end