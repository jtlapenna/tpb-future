class ShopifyApiParser
  attr_reader :store

  def initialize(store_id:)
    @store = Store.find(store_id)
    @store.set_shopify_base_url
  end

  def parse
    store_sync = StoreSync.new(store_id: @store.id)
    result = { errors: [], sync: nil }
    errors = []

    begin
      products = []
      collection_ids = []
      collection_hash ={}
      product_hash = {}
      response = ShopifyAPI::Product.find(:all, params: { limit: 5 })
      collects = ShopifyAPI::Collect.all
      collection_ids = collects.map{|x| x.collection_id}.uniq
      collection_ids.map{|collection_id| collection_hash.merge!("#{collection_id}" => ShopifyAPI::Collection.find(collection_id).title) }
      collects.each do |collect|
        product_hash["#{collect.collection_id}"] = Array.new  if product_hash["#{collect.collection_id}"].class != Array
        product_hash["#{collect.collection_id}"] << "#{collect.product_id}"
      end
      response.map{ |item| products << item if item.status == 'active' }

      loop do
        response = ShopifyAPI::Product.find(:all, params: { page_info: response.next_page_info, limit: 5 })
        response.map{ |item| products << item if item.status == 'active' }
      break if response.next_page_info.nil?
      end

      # Keep all the product variants, and delete the Parent product
      all_variants = products.map{|product| product.variants.map{|varinat| "#{product.id}:#{varinat.id}"}}.flatten
      store.store_products.where.not(sku: all_variants).update_all(stock: 0, status: 0)

      products.each_with_index do |api_prod, index|
        tags = api_prod.tags.present? ? api_prod.tags.split(', ') : []
        product_type = api_prod.product_type.present? ? api_prod.product_type : 'uncategorised'

        api_prod.variants.each do |prod_variant|
          images = {}
          api_prod_images = api_prod.images
          own_images_ary = api_prod_images.select{ |image| image.variant_ids.include?(prod_variant.id) }

          if own_images_ary.present?
            images[:primary] = own_images_ary.first.src
            images[:thumb] = own_images_ary.first.src
            images[:all_images] = api_prod_images.map{|image| image.src}
          elsif api_prod_images.present?
            images[:primary] = api_prod_images.first.src
            images[:thumb] = api_prod_images.first.src
            images[:all_images] = api_prod_images.map{|image| image.src}
          end

          prod_name = prod_variant.title == 'Default Title' ? api_prod.title : "#{api_prod.title}(#{prod_variant.title})"

          attributes = []
          if option = api_prod.options.detect{ |item| item.name == 'Size' }
            attributes.push(name: 'Size/Presentation', value: option.values.join(', '))
          end
          cat_tags_id =[]
          cat_tags = []
          product_hash.each do |key, val|
           cat_tags_id.append(key) if val.include? api_prod.id.to_s
          end
          collection_hash.map{|key, val| cat_tags.append(val) if cat_tags_id.include? key }
          cat_tags.delete("All Products")
          description_text = api_prod.body_html&.gsub(/<meta charset=\"utf-8\">\n/, '\1')
          item = StoreSyncItem.new(
            sku: "#{api_prod.id}:#{prod_variant.id}",
            name: prod_name,
            description: ActionView::Base.full_sanitizer.sanitize(description_text),
            size_name: api_prod.title,
            category: cat_tags.last,
            weight: weight_to_miligram(prod_variant.weight, prod_variant.weight_unit),
            stock: prod_variant.inventory_quantity.negative? ? 0 : (prod_variant.inventory_quantity || 0),
            brand: api_prod.vendor&.upcase,
            store_sync: store_sync,
            active: api_prod.status == 'active',
            images: images,
            tags: tags,
            attributes_values: attributes,
            prices: [{ name: '', value: prod_variant.price }],
          )

          if item.valid?
            store_sync.store_sync_items << item
          else
            Rails.logger.error "Error on SKU #{api_prod.id}"
            result[:errors] << { row: index + 1, messages: item.errors.messages }
            Rails.logger.error "#{item.errors.messages}"
          end
        end
      end
    rescue Exception => e
      raise raise Shopify::ShopifyError, "Shopify api error:"
    end

    store.clear_shopify_session

    result[:sync] = store_sync if result[:errors].blank? && store_sync.save
    result
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
