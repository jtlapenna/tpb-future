class Webhooks::TreezController < ActionController::API
  before_action :find_store
  before_action :parse_data

  def end_point
    puts "rails has received the webhooks ========================== with data #{params}"
    if event_type == 'PRODUCT'
        TreezLog.debug_webhooks("********** WEBHOOKS **********")
        TreezLog.debug_webhooks("Treez is giving this data for product #{@payload[:sku]}")
        TreezLog.debug_webhooks("Authorization =>")
        TreezLog.debug_webhooks("#{request.headers['Authorization']}")
        TreezLog.debug_webhooks("webhooks payload =>")
        TreezLog.debug_webhooks("#{@payload}")
      begin
        store_products = @store.store_products.where(sku: @payload[:sku], store_id: @store.id)
        productsCount = store_products.count
        if productsCount == 0 && @store.api_automatch
          product = api_client.get_product_by_id(@payload[:sku])
          existing_sku_in_bd = store_products.exists?(sku: @payload[:sku])
          puts "product is #{product} and existing_sku_in_bd is #{existing_sku_in_bd}"
          if product && !existing_sku_in_bd
            create_product!
          end
        elsif productsCount == 1
          cp = @store.store_products.find_by(sku: @payload[:sku], store_id: @store.id)
          update_existing_product(cp)
        elsif productsCount > 1

          # Send sentry notification
          Sentry.capture_message("Duplicated SKU: #{@payload[:sku]} and store_id: #{@store.id}", level: :warning)
          Rails.logger.error "Error on SKU #{@payload[:sku]} and store_id: #{@store.id}"

          # cp = @store.store_products.order("id").last
          #
          # StoreProduct.where(store_id: @store.id).where(sku: @payload[:sku]).where.not(id: cp[:id]).includes([:store_category, :product_variant, :taggings, :tag_taggings, :tags]).each do |store_product|
          #   store_product.update(sku: "#{cp[:sku]}-duplicated-#{store_product[:id]}", stock: 0)
          # end
          #
          # update_existing_product(cp)
        end
      rescue StandardError => e
        Rails.logger.info("======= API end_point failed =======")
        Rails.logger.info("Store Product: #{cp ? cp.inspect : nil}")
        Rails.logger.info("Payload: #{@payload.inspect}")
        Rails.logger.info("Exection: #{e}")
        Rails.logger.info("==============")
        Sentry.capture_exception(e, {
          extra: {
            payload: @payload,
            header_authorization: request.headers['Authorization'],
            cp: cp
          }
        })
      end
    elsif event_type == 'CUSTOMER'
      begin
        customer = @store.customers.find_or_initialize_by(customer_id: @payload[:customer_id])
        cleaned_payload = {}
        @payload.each do |key, value|
          cleaned_payload[key] = value.is_a?(String) ? value.scrub : value
        end
        customer.assign_attributes(cleaned_payload.merge(external_account_id: @store.api_key))
        customer.save
      rescue StandardError => e
        Sentry.capture_exception(e, {
          extra: {
            customer: customer
          }
        })
      end
    elsif event_type == 'TICKET'
      begin
        cust_order = @store.customer_orders.find_or_initialize_by(customer_id: @payload[:customer_id],
                                                                  order_id: @payload[:order_id])
        cust_order.save
        TreezLog.debug_webhooks("************************************ order wbbehook is recieved: #{data}")
        if order_status == 'COMPLETED'
          TreezLog.debug_webhooks("************************************ order wbbehook is COMPLETED: #{data}")
          all_items.each do |item|
            TreezLog.debug_webhooks("************************************ order wbbehook is COMPLETED for product: #{data}")
            #I am hitting the treez to update the single prodduct it will update the stock with lastest one
            # get_product is actually updating the product in the database.
            TreezApiParser.new(store_id: @store.id).get_product(item[:product_id])
            TreezLog.debug_webhooks("************************************ order wbbehook is done:")
          end
        end
      rescue StandardError => e
        Sentry.capture_exception(e, {
          extra: {
            cust_order: cust_order,
            all_items: all_items
          }
        })
      end
    end

    head :ok
  end

  private

  def api_client
    @api_client ||= Treez::ApiClient.new(@store.treez_api_config)
  end

  def parse_data
    @payload =
    if event_type == 'PRODUCT'
      Webhooks::Treez::StoreProduct.new(@store, data).parse
    elsif event_type == 'CUSTOMER'
      Webhooks::Treez::Customer.new(@store, data).parse
    elsif event_type == 'TICKET'
      Webhooks::Treez::CustomerOrder.new(@store, data).parse
    end
  end

  def event_type
    
    params['event_type']
  end

  def data
    params['data']
  end
  def order_status
    data[:order_status]
  end
  def all_items
    data[:items]
  end

  def find_store
    @store = Store.find(params[:store_id])
  end

  def store_category
    if @payload[:store_category_id].nil?
      return StoreCategory.where(
        name: data['category_type'].downcase,
        store_id: @store.id
      ).first_or_create
    end

    StoreCategory.find(@payload[:store_category_id])
  end

  def update_existing_product(cp)
    begin
      prices = (@payload[:prices] || []).map do |p|
        current_price = cp.product_values.find_by(name: p[:name])
        id = current_price ? current_price.id : nil
        {name: p[:name], value: p[:value], id: id}
      end
  
      prices_to_destroy = cp.product_values
                            .reject { |pv| prices.any? { |p| p[:id] == pv.id } }
                            .map { |pv| {id: pv.id, _destroy: true} }
  
      deactivated_item = @store.api_type_treez? && !@payload[:active]
      attrs = {
        stock: (deactivated_item ? 0 : @payload[:stock]),
        product_values_attributes: prices + prices_to_destroy,
        status: @payload[:status],
        latest_update_source: 'webhooks',
        latest_update_token: request.headers['Authorization'],
        inventory_type_medical: @payload[:inventory_type_medical]
      }
  
      if @store.override_on_sync
        attrs[:name] = @payload[:name] || cp.name
        attrs[:description] = (@payload[:description] || cp.description)&.scrub('')
        attrs[:store_category_id] =
        if @store.preserve_category
          cp.store_category_id
        else
          @payload[:store_category_id] || StoreCategory.where(name: data['category_type'].downcase,store_id: @store.id).first_or_create[:id]
        end
  
        attrs[:brand_id] = @payload[:brand_id] || cp.brand_id
        attrs[:weight] = @payload[:weight] || cp.weight
  
        # only update primary, thumb image if modified
        alter_primary_image = false
        own_image = cp.own_images.find_by(url: @payload[:primary_image_url])
        if @payload[:primary_image_url].present?
          if own_image
            alter_primary_image = true if cp.primary_image_id.nil? || cp.thumb_image_id.nil? || cp.primary_image_id != own_image.id
          else
            alter_primary_image = true
          end
  
          if alter_primary_image
            @payload[:own_images] << @payload[:primary_image_url]
            cp.primary_image_url = @payload[:primary_image_url]
            cp.thumb_image_url = @payload[:primary_image_url]
          end
        end
  
        images = (@payload[:own_images]&.uniq || []).map do |image_url|
          own_image = cp.own_images.find_by(url: image_url)
          id = own_image ? own_image.id : nil
          {url: image_url, id: id}
        end
  
        own_images_to_destroy = cp.own_images.reject { |pv| images.any? { |p| p[:id] == pv.id } }.map { |pv| {id: pv.id, _destroy: true} }
        attrs[:own_images_attributes] = images + own_images_to_destroy
  
        if cp.primary_image_url.blank? && @payload[:own_images].present?
          # Image will be deleted when cp save, until then primary_image_id will be present
          assign_img = own_images_to_destroy.any?{|item| (item[:id] == cp.primary_image_id || item[:id] == cp.thumb_image_id) }
  
          if cp.primary_image_id.nil? || cp.thumb_image_id.nil? || assign_img
            cp.primary_image_url = @payload[:own_images].first
            cp.thumb_image_url = @payload[:own_images].first
          end
        end
  
        attribute_values = (@payload[:attribute_values] || []).map do |av|
          current_attr_val = cp.attribute_values.find_by(attribute_def_id: av[:attribute_def_id])
          id = current_attr_val ? current_attr_val.id : nil
          {attribute_def_id: av[:attribute_def_id], value: av[:value], id: id}
        end
  
        attr_values_to_destroy = cp.attribute_values
                                  .reject { |pv| attribute_values.any? { |p| p[:id] == pv.id } }
                                  .map { |pv| {id: pv.id, _destroy: true} }
        attrs[:attribute_values_attributes] = attribute_values + attr_values_to_destroy
  
        attrs[:tag_list] = @payload[:tags] if @store.sync_tags && @payload[:tags].present?
      end
  
      cp.update!(attrs)
    rescue StandardError => e
      Sentry.capture_exception(e, extra: { product_id: cp.id })
    end
  end

  def create_product!
    begin
      store_category.store_products.where(sku: @payload[:sku]).first_or_create!(
        store_category_id: @payload[:store_category_id],
        brand_id: @payload[:brand_id],
        product_variant_id: @payload[:product_variant_id],
        stock: @payload[:stock],
        sku: @payload[:sku],
        weight: @payload[:weight],
        name: @payload[:name],
        description: @payload[:description],
        latest_update_source: 'webhooks',
        latest_update_token: request.headers['Authorization'],
        product_values_attributes: @payload[:prices],
        own_images_attributes: @payload[:own_images].map{|image| {url: image}},
        primary_image_url: @payload[:primary_image_url],
        thumb_image_url: @payload[:thumb_image_url] || @payload[:primary_image_url],
        tag_list: (@store.sync_tags ? @payload[:tags] : []),
        attribute_values_attributes: @payload[:attribute_values],
        inventory_type_medical: @payload[:inventory_type_medical]
      )
    rescue StandardError => e
      Sentry.capture_exception(e, {
        extra: {
          payload: @payload,
          header_authorization: request.headers['Authorization']
        }
      })
    end
  end
end
