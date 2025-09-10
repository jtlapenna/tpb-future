class Webhooks::Shopify::StoreProduct < Webhooks::Shopify::Base
  def parse
    collection_ids = []
    collection_hash ={}
    product_hash = {}
    product_type = payload['product_type'].present? ? payload['product_type'] : 'uncategorised'
    brand_id = Brand.find_or_create_by(name: payload['vendor']&.upcase).id

    store.set_shopify_base_url
    collects = ShopifyAPI::Collect.all
    collection_ids = collects.map{|x| x.collection_id}.uniq
    collection_ids.map{|collection_id| collection_hash.merge!("#{collection_id}" => ShopifyAPI::Collection.find(collection_id).title) }
    collects.each do |collect|
      product_hash["#{collect.collection_id}"] = Array.new  if product_hash["#{collect.collection_id}"].class != Array
      product_hash["#{collect.collection_id}"] << "#{collect.product_id}"
    end
    cat_tags_id =[]
    cat_tags = []
    product_hash.each do |key, val|
      cat_tags_id.append(key) if val.include? payload['id'].to_s
    end
    collection_hash.map{|key, val| cat_tags.append(val) if cat_tags_id.include? key }
    cat_tags.delete("All Products")
    store_category_id = StoreCategory.find_or_create_by(name:  cat_tags.last, store_id: store.id)&.id
    tags = payload['tags'].present? ? payload['tags'].split(', ') : []

    payload['variants'].map do |prod_variant|
      prod_name = prod_variant['title'] == 'Default Title' ? payload['title'] : "#{payload['title']}(#{prod_variant['title']})"
      own_images_ary = payload['images'].select{ |image| image['variant_ids'].include?(prod_variant['id']) }
      primary_image_url = own_images_ary.present? ? own_images_ary.first['src'] : nil

      images = payload['images'].map{|image| image['src']} || []
      images << primary_image_url if primary_image_url.present? && images.exclude?(primary_image_url)

      stock_value =
      if prod_variant['inventory_quantity'].negative? || prod_variant['inventory_quantity'].nil? || !status_active?
        0
      else
        prod_variant['inventory_quantity']
      end

      {
        store_category_id: store_category_id,
        brand_id: brand_id,
        product_variant_id: ENV['WILDCARD_VARIANT_ID'],
        active: status_active?,


        stock: stock_value,
        sku: "#{payload['id']}:#{prod_variant['id']}",
        weight: weight_to_miligram(prod_variant['weight'], prod_variant['weight_unit']),
        name: prod_name,
        description: payload['body_html'],
        status: status_active? ? 1 : 0,
        prices: [{ name: '', value: prod_variant['price'] }],
        own_images: images,
        primary_image_url: primary_image_url,
        thumb_image_url: primary_image_url,
        attribute_values: [],
        tags: tags
      }
    end
  end

  private

  def status_active?
    payload['status'] == 'active'
  end

  def weight_to_miligram(weight_val, weight_unit)
    # storing weight in miligram
    gram =
    case weight_unit
    when 'lb'
      weight_val * 453.592
    when 'oz'
      weight_val * 28.3495
    when 'kg'
      weight_val * 1000
    else
      weight_val
    end

    gram * 1000
  end
end
