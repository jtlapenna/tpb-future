class Webhooks::ShopifyController < ActionController::API
  before_action :find_store

  def product_create
    prod_variants = Webhooks::Shopify::StoreProduct.new(@store, params).parse

    prod_variants.each do |payload|
      create_store_product!(payload)
    end

    head :ok
  end

  def product_update
    prod_variants = Webhooks::Shopify::StoreProduct.new(@store, params).parse

    if prod_variants.present?
      variant_skus = prod_variants.map{|item| item[:sku]}
      parent_sku = variant_skus[0].split(':')[0] || variant_skus[0][:sku]

      products = @store.store_products.sku_like(parent_sku)

      prods = products.where.not(sku: variant_skus)
      prods.update_all(stock: 0, status: 0) if prods.present?
    end

    prod_variants.each do |payload|
      if cp = @store.store_products.find_by(sku: payload[:sku])
        prices = (payload[:prices] || []).map do |p|
          current_price = cp.product_values.find_by(name: p[:name])
          id = current_price ? current_price.id : nil
          {name: p[:name], value: p[:value], id: id}
        end

        prices_to_destroy = cp.product_values
                              .reject { |pv| prices.any? { |p| p[:id] == pv.id } }
                              .map { |pv| {id: pv.id, _destroy: true} }

        attrs = {
          stock: (!payload[:active] ? 0 : payload[:stock]),
          product_values_attributes: prices + prices_to_destroy,
          status: payload[:status],
          latest_update_source: 'webhooks'
        }

        if @store.override_on_sync
          attrs[:name] = payload[:name] || cp.name
          attrs[:description] = ActionView::Base.full_sanitizer.sanitize(payload[:description]) || cp.description
          attrs[:store_category_id] =
          if @store.preserve_category
            cp.store_category_id
          else
            payload[:store_category_id] || cp.store_category_id
          end

          attrs[:brand_id] = payload[:brand_id] || cp.brand_id
          attrs[:weight] = payload[:weight] || cp.weight

          # only update primary, thumb image if modified
          alter_primary_image = false
          own_image = cp.own_images.find_by(url: payload[:primary_image_url])
          if payload[:primary_image_url].present?
            if own_image
              alter_primary_image = true if cp.primary_image_id.nil? || cp.thumb_image_id.nil? || cp.primary_image_id != own_image.id
            else
              alter_primary_image = true
            end

            if alter_primary_image
              payload[:own_images] << payload[:primary_image_url]
              cp.primary_image_url = payload[:primary_image_url]
              cp.thumb_image_url = payload[:primary_image_url]
            end
          end

          images = (payload[:own_images]&.uniq || []).map do |image_url|
            own_image = cp.own_images.find_by(url: image_url)
            id = own_image ? own_image.id : nil
            {url: image_url, id: id}
          end

          own_images_to_destroy = cp.own_images.reject { |pv| images.any? { |p| p[:id] == pv.id } }.map { |pv| {id: pv.id, _destroy: true} }
          attrs[:own_images_attributes] = images + own_images_to_destroy

          if cp.primary_image_url.blank? && payload[:own_images].present?
            # Image will be deleted when cp save, until then primary_image_id will be present
            assign_img = own_images_to_destroy.any?{|item| (item[:id] == cp.primary_image_id || item[:id] == cp.thumb_image_id) }

            if cp.primary_image_id.nil? || cp.thumb_image_id.nil? || assign_img
              cp.primary_image_url = payload[:own_images].first
              cp.thumb_image_url = payload[:own_images].first
            end
          end

          attribute_values = (payload[:attribute_values] || []).map do |av|
            current_attr_val = cp.attribute_values.find_by(attribute_def_id: av[:attribute_def_id])
            id = current_attr_val ? current_attr_val.id : nil
            {attribute_def_id: av[:attribute_def_id], value: av[:value], id: id}
          end

          attr_values_to_destroy = cp.attribute_values
                                    .reject { |pv| attribute_values.any? { |p| p[:id] == pv.id } }
                                    .map { |pv| {id: pv.id, _destroy: true} }
          attrs[:attribute_values_attributes] = attribute_values + attr_values_to_destroy

          attrs[:tag_list] = payload[:tags] if @store.sync_tags && payload[:tags].present?
        end

        cp.update!(attrs)
      else
        create_store_product!(payload)
      end
    end

    head :ok
  end

  def product_delete
    products = @store.store_products.sku_like(params[:id])
    products.update_all(stock: 0, status: 0) if products.present?

    head :ok
  end

  def order_create
    landing_site = params[:landing_site].to_s
    site = landing_site.split("Store=")[1] || landing_site.split("store=")[1]
    if site.present?
      @store.set_shopify_base_url
      order = ShopifyAPI::Order.new
      order.id = params[:id]
      order.tags = @store.name
      order.save!
    end
  end

  def order_update
  end

  private

  def find_store
    @store = Store.find(params[:store_id])
  end

  def store_category(store_category_id)
    StoreCategory.find(store_category_id)
  end

  def create_store_product!(payload)
    store_category(payload[:store_category_id]).store_products.where(sku: payload[:sku]).first_or_create!(
      store_category_id: payload[:store_category_id],
      brand_id: payload[:brand_id],
      product_variant_id: payload[:product_variant_id],
      stock: payload[:stock],
      sku: payload[:sku],
      weight: payload[:weight],
      name: payload[:name],
      description: ActionView::Base.full_sanitizer.sanitize(payload[:description]),
      product_values_attributes: payload[:prices],
      own_images_attributes: payload[:own_images].map{|image| {url: image}},
      primary_image_url: payload[:primary_image_url],
      thumb_image_url: payload[:thumb_image_url] || payload[:primary_image_url],
      tag_list: payload[:tags],
      latest_update_source: 'webhooks',
      attribute_values_attributes: payload[:attribute_values]
    )
  end
end
