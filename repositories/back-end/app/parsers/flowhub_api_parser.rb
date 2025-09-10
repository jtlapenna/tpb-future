require 'csv'

class FlowhubApiParser
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

    products.each_with_index do |api_prod, index|
      product_name = sanitize_string(api_prod[:productName])
      species_name = sanitize_string(api_prod[:speciesName])

      images = {}
      if api_prod[:productPictureURL].present?
        images[:primary] = api_prod[:productPictureURL]
        images[:thumb] = images[:primary]
      end

      if preroll_default_picture.present? && api_prod[:category].downcase == 'joint'
        images[:primary] = preroll_default_picture
        images[:thumb] = preroll_default_picture
      end
      attributes = generate_cannabis_attributes(api_prod[:cannabinoidInformation])
      if attributes
        attributes << generate_type_attribute(species_name) if species_name.present?
      end

      is_product_active = true

      size_name = product_name
      product_gram_weight = gram_weight(api_prod)
      if %w[bulkbud packedbud bulkshake packedshake].include? api_prod[:category].downcase
        size_name += " (#{api_prod[:productWeight]}#{api_prod[:productUnitOfMeasure]})"

        price_present = lambda do |weight_tier|
          weight_tier[:pricePerUnitInMinorUnits].present? &&
            weight_tier[:gramAmount].present?
        end
        price_for_weight = ->(weight_tier) { weight_tier[:gramAmount] == product_gram_weight }

        prices = api_prod[:weightTierInformation]
                 .select(&price_for_weight)
                 .select(&price_present)
                 .sort_by { |weight_tier| weight_tier[:pricePerUnitInMinorUnits].to_i }
                 .map do |weight_tier|
                   {
                     name: '',
                     value: weight_tier[:pricePerUnitInMinorUnits].to_f / 100
                   }
                 end
      else
        prices = [{
          name: '',
          value: api_prod[:priceInMinorUnits].to_f / 100
        }]
      end

      weight = product_gram_weight.zero? ? cannabinoid_gram_weight(api_prod) : product_gram_weight
      item = StoreSyncItem.new(
        sku: api_prod[:productId],
        name: size_name,
        size_name: size_name,
        description: api_prod[:productDescription],
        weight: (weight * 1000).to_i,
        category: translate_category(api_prod[:category]),
        stock: api_prod[:quantity],
        brand: sanitize_string(api_prod[:brand]),
        store_sync: store_sync,
        active: is_product_active,
        prices: prices,
        images: images || [],
        tags: [],
        attributes_values: store[:api_settings][:use_total_thc] ? thca_potency(attributes, translate_category(api_prod[:category])) : attributes
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

  private

  def generate_cannabis_attributes(prod_attributes)
    if(prod_attributes.nil?)
      return nil;
    end

    prod_attributes
      .select { |attribute| attribute[:name] =~ /^thc|cbd$/i }
      .map do |attribute|
        range = attribute[:upperRange]
        if attribute[:unitOfMeasure] == "%"
          formatted_range = sprintf("%.2f", range).gsub(/\.0+$/, "")
        
          value = "#{formatted_range} %"
        else
          value = "#{range} #{attribute[:unitOfMeasure]}"
        end

        { name: attribute[:name].upcase, value: value }
      end
  end

  def generate_type_attribute(species_name)
    type_value = species_name.split('-').first.to_s.downcase

    { name: 'TYPE', value: type_value }
  end

  def products
    prods = api_client.products
    prod_filter = store.customer_type_filter
    prod_filter.present? ? filter_prod(prods, prod_filter) : prods
  end

  def filter_prod(products, prod_filter)
    products.filter do |api_prod|
      allow_customer_type = prod_filter == "#{api_prod[:purchaseCategory]}Customer"
      api_prod[:purchaseCategory] == 'unrestricted' || allow_customer_type
    end
  end

  def store_customer_filter
    store.customer_type_filter
  end

  def api_client
    @api_client ||= Flowhub::ApiClient.new(store.flowhub_api_config)
  end

  def sanitize_string(value)
    return value if value.blank?

    value.squish
  end

  def translate_category(value)
    category_translations[value.downcase] || value
  end

  def category_translations
    @category_translations ||= {
      'packedbud' => 'Flower',
      'joint' => 'Pre-Roll'
    }
  end

  def gram_weight(api_prod)
    product_weight = api_prod[:productWeight]

    product_weight_multiplier = api_prod[:productUnitOfMeasureToGramsMultiplier].to_f

    # NOTE: unitOfMeasureToGramsMultiplier is set as 1000 instead of 0.001.
    # 0.001 is hardcoded because exist an issue https://trello.com/c/1XaueDtv
    # this is temporal until it got fixed
    product_weight_multiplier = 0.001 if api_prod[:productUnitOfMeasure] == 'mg'

    product_weight_multiplier = 1 if category_in_grams?(api_prod[:category])

    if product_weight.nil?
      return 0
    end

    product_weight * product_weight_multiplier
  end

  def cannabinoid_gram_weight(api_prod)
    cannabinoid_information = api_prod[:cannabinoidInformation] || []

    info_to_weight = lambda do |info|
      weight = [info[:lowerRange], info[:upperRange]].compact.max
      # NOTE: unitOfMeasureToGramsMultiplier is set as 1000 instead of 0.001.
      # 0.001 is hardcoded because we are filtering by mg unit of measure
      multiplier = 0.001

      weight * multiplier
    end

    cannabinoid_information
      .select { |info| info[:unitOfMeasure] == 'mg' }
      .map(&info_to_weight)
      .reject { |value| value.is_a?(String) && value.empty? }
      .sum
  end

  def preroll_default_picture
    @preroll_default_picture ||= ENV['FLOWHUB_PREROLL_IMAGE_URL']
  end

  # NOTE: edible and concentrate products have productUnitOfMeasure with 'mg'.
  # Based on the name (example: 'xxxx 1g') they should had but they have 'g'. We spoke with
  # Happy Valley (currently the only flowhub client) and they said that they are not going to
  # change their inventory data. So there is no other options than make this patch.
  def category_in_grams?(prod_category)
    return if prod_category.blank?

    %w[edible concentrate].any? { |category| prod_category.downcase == category }
  end

  def thca_potency(value, category)
    begin
      if value
        thca_obj = value.find { |obj| obj[:name] == "THC-A" }
        thca_value = thca_obj && thca_obj[:value].include?("%") ? thca_obj[:value].to_f : 0.0
      
        thc_obj = value.find { |obj| obj[:name] == "THC" }
        thc_value = thc_obj && thc_obj[:value].include?("%") ? thc_obj[:value].to_f : 0.0
      
        modified_array = value.map do |obj|
          if (obj[:name] == "THC" && obj[:value].include?("%") && ["flower", "flowers"].include?(category.downcase))
            new_thc_value = (thca_value * 0.877) + thc_value
            obj[:value] = "#{new_thc_value.round(1)}%"
          end
          obj
        end
        
        return modified_array
      else
        return []
      end
    rescue StandardError => e
      Sentry.capture_exception(e)
      return []
    end
  end
end
