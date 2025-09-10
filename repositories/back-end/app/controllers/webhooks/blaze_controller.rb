class Webhooks::BlazeController < ActionController::API
  before_action :find_store
  before_action :parse_data

  def end_point
    puts "rails has received the webhooks ========================== with data #{params}"
    begin
      if cp = @store.store_products.find_by(sku: @payload[:sku])
        update_existing_product(cp)
      elsif @store.api_automatch
        create_product!
      end
    rescue Exception => e
      Rails.logger.info("======= API end_point failed =======")
      Rails.logger.info("Store Product: #{cp ? cp.inspect : nil}")
      Rails.logger.info("Payload: #{@payload.inspect}")
      Rails.logger.info("Exection: #{e}")
      Rails.logger.info("==============")
    end

    head :ok
  end

  private

  def parse_data
    @payload = Webhooks::Blaze::StoreProduct.new(@store, data).parse
  end

  def data
    params
  end

  def find_store
    @store = Store.find(params[:store_id])
  end

  def store_category
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
  
      deactivated_item = @store.api_type_blaze? && !@payload[:active]
      attrs = {
        stock: (deactivated_item ? 0 : @payload[:stock]),
        product_values_attributes: prices + prices_to_destroy,
        status: @payload[:status],
        latest_update_source: 'webhooks',
      }
  
      if @store.override_on_sync
        attrs[:name] = @payload[:name] || cp.name
        attrs[:description] = @payload[:description] || cp.description
        attrs[:store_category_id] =
          if @store.preserve_category
            cp.store_category_id
          else
            @payload[:store_category_id] || cp.store_category_id
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
    rescue Exception => e
      Sentry.capture_exception(e, {
        extra: {
          cp: cp,
          attrs: attrs
        }
      })
      return cp
    end
  end

  def create_product!
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
      product_values_attributes: @payload[:prices],
      own_images_attributes: @payload[:own_images].map{|image| {url: image}},
      primary_image_url: @payload[:primary_image_url],
      thumb_image_url: @payload[:thumb_image_url] || @payload[:primary_image_url],
      tag_list: (@store.sync_tags ? @payload[:tags] : []),
      attribute_values_attributes: @payload[:attribute_values],
    )
  end
end
