class KiosksController < ApplicationController
  include Paged
  include Sortable

  before_action :find_kiosk, only: %i[show update clone]
  before_action :find_store, only: %i[clone]
  before_action :set_paper_trail_whodunnit


  def index
    authorize Kiosk

    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";

    kiosks = policy_scope(Kiosk)
             .joins(:store)
             .includes(:layout, :store, :taggings)
             .page(page).per(page_size).order(order_fields)
             .where('kiosks.name ILIKE ? OR stores.name ILIKE ?',q,q)
    render json: kiosks, meta: pagination_dict(kiosks)
  end

  def clone
    authorize @kiosk

    kiosk_new_name = params[:kiosk_new_name] != nil ? params[:kiosk_new_name] : nil;    
    result = CloneKioskOperation.new.call(@kiosk, @store, kiosk_new_name)

    if result.success?
      render json: result.value!, status: :created
    else
      errors = result.value!.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def create
    authorize Kiosk

    kiosk = Kiosk.new(permitted_attributes(Kiosk))

    if kiosk.save
      render json: kiosk, status: :created
    else
      errors = kiosk.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @kiosk

    Rails.logger.info("Updating Kiosk and maybe rfids")
    Rails.logger.info(params.inspect)
    brand_and_store_category_to_deletes = []

    for rfid_updated in (params["kiosk"]["rfid_products_attributes"] || [])
      if rfid_updated["rfid_entity_type"] == "BrandAndStoreCategory"
        if rfid_updated["rfid_entity_id"] && rfid_updated["rfid_sub_entity_id"]
          if !rfid_updated["_destroy"]
            if rfid_updated["id"].nil?
              # Create new BrandAndStoreCategory
              brand_and_store_category = BrandAndStoreCategory.create(brand_id: rfid_updated["rfid_entity_id"], store_category_id: rfid_updated["rfid_sub_entity_id"], kiosk_id: @kiosk.id)

              if brand_and_store_category.errors.any?
                render json: { errors: brand_and_store_category.errors.as_json }
                return
              else
                rfid_updated["rfid_entity_id"] = brand_and_store_category.id
              end
            else
              # Update BrandAndStoreCategory
              rfid_product = RfidProduct.find(rfid_updated["id"])
              brand_and_store_category = BrandAndStoreCategory.find(rfid_product.rfid_entity_id)
              brand_and_store_category.update(brand_id: rfid_updated["rfid_entity_id"], store_category_id: rfid_updated["rfid_sub_entity_id"], kiosk_id: @kiosk.id)

              rfid_updated["rfid_entity_id"] = rfid_product.rfid_entity_id
            end
          else
            # Delete BrandAndStoreCategory
            rfid_product = RfidProduct.find(rfid_updated["id"])
            brand_and_store_category = BrandAndStoreCategory.find_by(id: rfid_product.rfid_entity_id)
            brand_and_store_category_to_deletes.push(brand_and_store_category) if brand_and_store_category
          end
        else
          render json: { errors: "BrandAndStoreCategory must have brand_id and store_category_id" }
          return
        end
      end
    end

    if @kiosk.update(permitted_attributes(@kiosk))
      for rfid_updated in (params["kiosk"]["rfid_products_attributes"] || []) do
        if (rfid_updated["rfid_entity_type"] == "KioskProduct") && rfid_updated["rfid_entity_id"]
          kiosk_product = KioskProduct.find(rfid_updated["rfid_entity_id"])
          kiosk_product.touch
          StoreProduct.find(kiosk_product.store_product_id).touch
        end
      end

      # Delete BrandAndStoreCategory
      brand_and_store_category_to_deletes.each do |brand_and_store_category_to_delete|
        brand_and_store_category_to_delete.destroy
      end
      render json: @kiosk
    else
      errors = @kiosk.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @kiosk

    render json: @kiosk, scope: current_user
  end

  private

  def find_kiosk
    @kiosk ||= policy_scope(Kiosk).find(params[:id])
  end

  def find_store
    if( params[:from_store_id] != nil ) then
      @store ||= policy_scope(Store).find(params[:from_store_id])
    else
      @store = nil
    end
  end

  def order_by
    return 'stores.name' if params[:sort_by] == 'store.name'

    super
  end
end
