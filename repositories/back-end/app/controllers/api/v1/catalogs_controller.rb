class Api::V1::CatalogsController < Api::V1::ApplicationController
  def settings
    kiosk_s = ActiveModelSerializers::SerializableResource.new(
      kiosk,
      serializer: Api::V1::KioskSerializer,
      root: 'catalog',
      include: [
        'layout.store_assets.pictures_in_pictures.asset',
        'layout.store_assets.dots.asset',
        'layout.welcome_asset.asset',
        'layout.video_image_background_asset.asset',
        'layout.store_assets.asset',
        'layout.navigation.items.asset',
        'layout.store_category',
        'layout.store_categories',
        'ad_configs.asset',
        'ad_configs.store_product'
      ]
    )
    store_s = ActiveModelSerializers::SerializableResource.new(
      kiosk.store,
      serializer: Api::V1::StoreSerializer,
      include: [
        'logo',
        'settings.background_media'
      ]
    )
    store_json = store_s.as_json
    if layout = kiosk.layout
      layout_s = ActiveModelSerializers::SerializableResource.new(
        layout,
        serializer: Api::V1::KioskLayoutSerializer,
        root: 'layout',
        include: [
          'store_assets.pictures_in_pictures.asset',
          'store_assets.dots.asset',
          'welcome_asset.asset',
          'video_image_background_asset.asset',
          'store_assets.asset',
          'navigation.items.asset',
          'store_categories'
        ]
      )
      store_json[:store].merge!(layout_s.as_json)
    end
    
    payment_gateway_data = PaymentGateway.where(store_id: kiosk.store.id).first
    payment_gateway = ActiveModelSerializers::SerializableResource.new(
      payment_gateway_data
    )
    payment_gateway_j = payment_gateway.as_json


    if payment_gateway_j != nil
      render json: kiosk_s.as_json.merge(store_json, payment_gateway_j)
    else
      render json: kiosk_s.as_json.merge(store_json)
    end
  end
  
  def tags
    render json: { tags: find_tags }
  end
  def rfids
    fields = [
      "#{RfidProduct.arel_table.name}.*",
      "store_products.id as store_product_id",
      "store_products.stock as stock"
    ]
    kiosks_query =  RfidProduct
                          .joins("left outer join kiosk_products on kiosk_products.id = rfid_products.rfid_entity_id and rfid_products.rfid_entity_type='KioskProduct'")
                          .joins("left outer join store_products on store_products.id = kiosk_products.store_product_id")
                          .joins("left outer join brands on brands.id = rfid_products.rfid_entity_id and rfid_products.rfid_entity_type='Brand'")
                          .joins("left outer join store_categories on store_categories.id = rfid_products.rfid_entity_id and rfid_products.rfid_entity_type='StoreCategory'")
                          .where("rfid_products.kiosk_id = #{kiosk.id}")
    #return render json: kiosks_query
      max_date = kiosks_query.maximum('rfid_products.updated_at')
    from_date = params[:max_date]
    rfids= kiosks_query.sorted.select(fields)
    if (from_date and !from_date.empty?)
      begin
        rfids= kiosks_query.sorted.select(fields).where('rfid_products.updated_at > ?', from_date.to_time+1)
      rescue StandardError => e
        Rails.logger.error "Error in getting rfid products from kiosks: #{e.message}"
        Rails.logger.error e
      end
    end
    rfids = rfids.reorder(order: :asc)
    rfid_serialized = ActiveModelSerializers::SerializableResource.new(rfids, root: 'rfids', each_serializer: Api::V1::RfidProductSerializer).as_json
    rfid_serialized[:max_date] = max_date
    rfid_serialized[:rfids].each do |rfid|
      if rfid[:rfid_entity_type] == 'BrandAndStoreCategory'
        begin
          brand_and_category = BrandAndStoreCategory.find(rfid[:rfid_entity_id])
          rfid[:rfid_entity_id] = brand_and_category.brand_id
          rfid[:rfid_sub_entity_id] = brand_and_category.store_category_id
          rfid[:category_name] = StoreCategory.find(brand_and_category.store_category_id).name
          rfid[:brand_name] = Brand.find(brand_and_category.brand_id).name
        rescue StandardError => e
          Rails.logger.error "Error in getting rfid products from brand and store category: #{e.message}"
          Rails.logger.error e
          next
        end
      end
    end
    return render json: rfid_serialized
  end
  def widgets
    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";
    render  json: kiosk.store.ad_banners.all,
            each_serializer: Api::V1::AdBannerSerializer
  end
  private
  def find_tags
    if params[:featured_tags] == 'true'
      kiosk.tag_list
    else
      kiosk.products_tags.map(&:name)
    end
  end
end
