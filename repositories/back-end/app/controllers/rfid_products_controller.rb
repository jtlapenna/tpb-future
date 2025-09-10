class RfidProductsController < ApplicationController
  include Paged
  #include Sortable
  before_action :find_kiosk

  def index
    authorize RfidProduct
    searchBy = params[:filter] != nil ? "%" + params[:filter] + "%" : "%";
    
    if (@kiosk.rfid_behavior == "1" && params[:rfid_entity] == 'Brand')
      rfids = @kiosk.rfid_products.order(order: :ASC).page(page).per(page_size).where('rfid_products.rfid_entity_type = ?', 'Brand').where('rfid_products.rfid LIKE ?', searchBy)      
    elsif (@kiosk.rfid_behavior == "1" && params[:rfid_entity] == 'StoreCategory')
      rfids = @kiosk.rfid_products.order(order: :ASC).page(page).per(page_size).where('rfid_products.rfid_entity_type = ?', 'StoreCategory').where('rfid_products.rfid LIKE ?', searchBy)
    elsif (@kiosk.rfid_behavior == "1" && params[:rfid_entity] == 'BrandAndStoreCategory')
      rfids = @kiosk.rfid_products.order(order: :ASC).page(page).per(page_size).where('rfid_products.rfid_entity_type = ?' , 'BrandAndStoreCategory').where('rfid_products.rfid LIKE ?', searchBy)
    else
      rfids = @kiosk.rfid_products.left_joins(:kiosk_product).includes(kiosk_product: :store_product).order(order: :ASC).page(page).per(page_size).where({rfid_products: {rfid_entity_type: [nil, 'KioskProduct']}}).where('rfid_products.rfid ILIKE ?', searchBy)

      if (@kiosk.rfid_sorting == "1")
        rfids = @kiosk.rfid_products.left_joins(:kiosk_product).includes(kiosk_product: :store_product).sorted_by_availability.page(page).per(page_size).where({rfid_products: {rfid_entity_type: [nil, 'KioskProduct']}}).where('rfid_products.rfid ILIKE ?', searchBy)
      end
    end

    if @kiosk.rfid_behavior == "1" && params[:rfid_entity] == 'BrandAndStoreCategory'
      rfids = rfids.includes(:brand_and_store_category)
      rfids.each do |rfid_product|
        if rfid_product.brand_and_store_category.present?
          brand_and_category = rfid_product.brand_and_store_category

          rfid_product.rfid_entity_id = brand_and_category.brand_id
          rfid_product_name = Brand.find(brand_and_category.brand_id).name

          rfid_product.define_singleton_method(:rfid_sub_entity_id) do
            brand_and_category.store_category_id
          end
          rfid_product.define_singleton_method(:name) do
            rfid_product_name
          end
        end
      end
    end

    r = ActiveModel::Serializer::CollectionSerializer.new(rfids, each_serializer: RfidProductSerializer)

    render json: {sorting: @kiosk.rfid_sorting, rfid_products: r, meta: pagination_dict(rfids)}
  end

  def create
    authorize RfidProduct
    rfid = RfidProduct.new(permitted_attributes(RfidProduct))

    if rfid.save
      render json: rfid, status: :created
    else
      errors = rfid.errors.as_json
      render json: {errors: errors}, status: :unprocessable_entity
    end
  end

  def new
    rfid_product_by_brand_and_store_category_ids = RfidProduct.where(kiosk_id: @kiosk.id, rfid_entity_type: 'BrandAndStoreCategory').pluck(:rfid_entity_id)
    brand_and_store_category_ids = BrandAndStoreCategory.where(kiosk_id: @kiosk.id).pluck(:id)
    extra_brand_and_store_category_ids = brand_and_store_category_ids - rfid_product_by_brand_and_store_category_ids
    BrandAndStoreCategory.where(id: extra_brand_and_store_category_ids).destroy_all
    render json: {rfidProduct: RfidProduct.where(kiosk_id: @kiosk.id, rfid: params[:rfid]).first!}
  end

  def change_history
    render json: PaperTrail::Version.where(item: @kiosk.rfid_products).order('created_at desc'),
           each_serializer: VersionSerializer
  end

  private

  def find_kiosk
    @kiosk = policy_scope(Kiosk).find(params[:kiosk_id])
  end
end
