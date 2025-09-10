class Webhooks::Treez::StoreProduct < Webhooks::Treez::Base

  def parse
    inventory_type_medical = payload[:sellable_quantity_detail].map{|a| a[:inventory_type]}.include?("MEDICAL")
    {
      store_category_id: store_category_id,
      brand_id: brand_id,
      product_variant_id: ENV['WILDCARD_VARIANT_ID'],
      active: payload['product_status'] == 'ACTIVE' && !payload['e_commerce']['hide_from_menu'],
      stock: stock_value,
      sku: payload['product_id'],
      weight: weight,
      name: product_configurable_fields['name'],
      description: e_commerce['product_description'],
      status: product_status,
      prices: [{ name: '', value: payload['pricing']['price_sell'] != nil ? payload['pricing']['price_sell'] : 0 }],
      own_images: own_images,
      primary_image_url: primary_image_url,
      thumb_image_url: primary_image_url,
      attribute_values: attribute_values,
      tags: (payload['attributes']['effects'] || []).map(&:downcase),
      inventory_type_medical: inventory_type_medical
    }
  end

  private

  def e_commerce
    payload['e_commerce']
  end

  def primary_image_url
    e_commerce['primary_image']
  end

  def own_images
    images = e_commerce['all_images'] || []
    images << primary_image_url if primary_image_url.present? && images.exclude?(primary_image_url)

    images
  end

  def product_configurable_fields
    payload['product_configurable_fields']
  end

  def weight
    product_configurable_fields['total_flower_weight_g'] * 1000 # storing in miligram
  end

  def product_status
    %w[DEACTIVATED DELETED].include?(payload['product_status']) ? 0 : 1
  end

  def brand_id
    if product_configurable_fields['brand'].present?
      Brand.find_or_create_by(name: product_configurable_fields['brand']&.upcase).id
    end
  end

  def store_category_id
    store.store_categories.where("lower(#{StoreCategory.table_name}.name) = ?", payload['category_type'].to_s.downcase).first_or_create&.id
    #StoreCategory.find_or_create_by(name: payload['category_type'].downcase, store_id: store.id)&.id
  end

  def stock_value
    store.api_automatch && payload['sellable_quantity'] >= e_commerce['minimum_visible_inventory_level'].to_i ? payload['sellable_quantity'] : 0
  end

  def get_thc(payload)
    if ((payload[:lab_results] == nil || payload[:lab_results] == []))
      return nil
    end

    thc_values = payload[:lab_results].select{ |result| result[:result_type] == 'THC' && result[:amount_type] == 'MG'};

    if (thc_values != nil && thc_values != [])
      return "#{thc_values[0][:amount][:minimum_value]} MG"
    end

    thc_percentage = payload[:lab_results].select{ |result| result[:result_type] == 'THC' && result[:amount_type] == 'PERCENTAGE'};

    if (thc_percentage != nil && thc_percentage != [])
      return "#{thc_percentage[0][:amount][:minimum_value]}%"
    end

    return nil

  end

  def get_cbd(payload)
    if ((payload[:lab_results] == nil || payload[:lab_results] == []))
      return nil
    end

    cbd_percentage = payload[:lab_results].select{ |result| result[:result_type] == 'CBD' && result[:amount_type] == 'PERCENTAGE'};

    if (cbd_percentage != nil && cbd_percentage != [])
      return "#{cbd_percentage[0][:amount][:minimum_value]}%"
    end

    cbd_values = payload[:lab_results].select{ |result| result[:result_type] == 'CBD' && result[:amount_type] == 'MG'};

    if (cbd_values != nil && cbd_values != [])
      return "#{cbd_values[0][:amount][:minimum_value]} MG"
    end

    return nil

  end

  def attribute_values
    attributes = []

    thc_values = get_thc(payload)

    att_def = AttributeDef.find_or_create_by(name: 'THC')
    if (thc_values != nil)
      attributes.push({ attribute_def_id: att_def.id, value: thc_values })
    elsif (total_mg_thc = payload[:product_configurable_fields][:total_mg_thc]).present?
      attributes.push({ attribute_def_id: att_def.id, value: total_mg_thc })
    end

    cbd_values = get_cbd(payload)

    att_def = AttributeDef.find_or_create_by(name: 'CBD')
    if (cbd_values != nil)
      attributes.push({ attribute_def_id: att_def.id, value: cbd_values })
    elsif (total_mg_cbd = payload[:product_configurable_fields][:total_mg_cbd]).present?
      attributes.push({ attribute_def_id: att_def.id, value: total_mg_cbd })
    end

    if (classification = payload.dig(:product_configurable_fields, :classification)).present?
      att_def = AttributeDef.find_or_create_by(name: 'Type')
      attributes.push({attribute_def_id: att_def.id, value: classification})
    end

    if (size = payload.dig(:product_configurable_fields, :size)).present?
      att_def = AttributeDef.find_or_create_by(name: 'Size/Presentation')
      attributes.push({attribute_def_id: att_def.id, value: size})
    end

    attributes
  end
end
