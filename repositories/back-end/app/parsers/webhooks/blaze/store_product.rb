class Webhooks::Blaze::StoreProduct < Webhooks::Blaze::Base

  def parse
    {
      store_category_id: store_category_id,
      brand_id: brand_id,
      product_variant_id: ENV['WILDCARD_VARIANT_ID'],
      active: payload[:active],
      stock: payload[:quantities] && payload[:quantities] != nil && payload[:quantities] != [] ? payload[:quantities][0][:quantity] : 0,
      sku: payload[:id],
      weight: get_weight_value,
      name: payload.dig(:name).to_s.strip,
      description: payload[:description],
      status: product_status,
      prices: [{ name: get_weight_name, value: get_prices }],
      own_images: own_images,
      primary_image_url: payload[:assets] && payload[:assets] != nil && payload[:assets] != [] ? payload[:assets][0][:publicURL] : [],
      thumb_image_url: payload[:category][:photo][:publicURL],
      attribute_values: attribute_values,
      tags: payload[:tags],
    }
  end

  private

  def own_images
    images = {}
    if payload[:assets] && payload[:assets] != nil && payload[:assets] != []
      images[:primary] = payload[:assets][0][:publicURL]
      images[:thumb] = payload[:assets][0][:publicURL]
    else
      images[:primary] = payload[:category][:photo][:publicURL]
      images[:thumb] = payload[:category][:photo][:publicURL]
    end
    images
  end

  def get_prices
    if (payload[:priceBreaks] != [])
      if (payload[:priceBreaks][0][:salePrice] != nil)
        return payload[:priceBreaks][0][:salePrice]
      else
        return 0
      end
    elsif (payload[:priceRanges] != [])
      value = payload[:priceRanges].find { |price| price[:weightTolerance]&.fetch(:weightValue, 0) == 1.0 }
      sale_price = value[:salePrice] if value
      return sale_price
    end
  end

  def get_weight_value
    if (payload[:weightPerUnit] === 'CUSTOM_GRAMS' && payload[:weightPerUnit] != nil)
      return payload[:customWeight]
    else
      return 0
    end
  end

  def get_weight_name
    if (payload[:weightPerUnit] != nil)
      if (payload[:weightPerUnit] == 'EACH')
        return 'Each'
      elsif (payload[:weightPerUnit] == 'HALF_GRAM')
        return 'Half Gram'
      elsif (payload[:weightPerUnit] == 'FULL_GRAM')
        return 'Gram'
      elsif (payload[:weightPerUnit] == 'EIGHTH')
        return 'Eighth'
      elsif (payload[:weightPerUnit] === 'CUSTOM_GRAMS')
        if (payload[:customGramType] === 'GRAM')
          return "#{payload[:customWeight]}g"
        else
          return "#{payload[:customWeight]}ml"
        end
      end
    end

    return ''
  end

  def product_status
    %w[DEACTIVATED DELETED].include?(payload['product_status']) ? 0 : 1
  end

  def brand_id
    Brand.find_or_create_by(name: payload[:brand][:name]&.upcase).id
  end

  def store_category_id
    store.store_categories.where("lower(#{StoreCategory.table_name}.name) = ?", payload[:category][:name].to_s.downcase).first_or_create&.id
  end

  def attribute_values
    attributes = []

    thc_values = get_thc

    att_def = AttributeDef.find_or_create_by(name: 'THC')
    if (thc_values != nil)
      attributes.push({ attribute_def_id: att_def.id, value: thc_values })
    elsif (total_mg_thc = payload[:potencyAmount][:thc]).present?
      attributes.push({ attribute_def_id: att_def.id, value: total_mg_thc })
    end

    cbd_values = get_cbd

    att_def = AttributeDef.find_or_create_by(name: 'CBD')
    if (cbd_values != nil)
      attributes.push({ attribute_def_id: att_def.id, value: cbd_values })
    elsif (total_mg_cbd = payload[:potencyAmount][:cbd]).present?
      attributes.push({ attribute_def_id: att_def.id, value: total_mg_cbd })
    end

    if (classification = payload[:flowerType]).present?
      att_def = AttributeDef.find_or_create_by(name: 'Type')
      attributes.push({attribute_def_id: att_def.id, value: classification})
    end

    attributes
  end

  def get_thc
    if ((payload[:potencyAmount] == nil || payload[:potencyAmount] == []))
      return nil
    end

    thc_values_mg = payload[:potencyAmount][:thc]

    if (thc_values_mg)
      return "#{thc_values_mg} MG"
    end

    thc_percentage = payload[:thc]

    if (thc_percentage)
      return "#{thc_percentage}%"
    end

    return nil
  end

  def get_cbd
    if ((payload[:potencyAmount] == nil || payload[:potencyAmount] == []))
      return nil
    end

    cbd_percentage = payload[:cbd]

    if (cbd_percentage)
      return "#{cbd_percentage}%"
    end

    cbd_values_thc = payload[:potencyAmount][:cbd]

    if (cbd_values_thc)
      return "#{cbd_values_thc} MG"
    end

    return nil
  end
end
