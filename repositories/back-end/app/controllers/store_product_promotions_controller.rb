class StoreProductPromotionsController < ApplicationController
    include Paged

    before_action :find_store_product_promotion, only: %i[show update destroy]
    before_action :find_store, only: %i[index]
    before_action :find_store_product, only: %i[create]

    # GET /store_product_promotions
    def index        
        authorize StoreProductPromotion
        enable_automate_promotions = @store.api_settings["enable_automate_promotions"]
        if(params[:filter] != nil)
            searchBy = params[:filter] != nil ? "%" + params[:filter] + "%" : "%"
            if enable_automate_promotions
                store_product_promotions = @store.store_product_promotions.left_joins(:store_product).includes(:store_product).page(page).per(page_size).where("store_product_promotions.promotion_id ILIKE ? OR store_product_promotions.promotion_name ILIKE ? OR store_products.name ILIKE ?", searchBy, searchBy, searchBy)
            else
                store_product_promotions = @store.store_product_promotions.left_joins(:store_product).includes(:store_product).page(page).per(page_size).where('store_products.name ILIKE ?', searchBy)
            end
        else
            store_product_promotions = @store.store_product_promotions.left_joins(:store_product).includes(:store_product).page(page).per(page_size)
        end

        # r = ActiveModel::Serializer::CollectionSerializer.new(store_product_promotions, each_serializer: StoreProductPromotionSerializer)
        render json: store_product_promotions, each_serializer: StoreProductPromotionSerializer, include: search_includes,  meta: pagination_dict(store_product_promotions, enable_automate_promotions)

        # render json: {store_product_promotions: r, meta: pagination_dict(store_product_promotions)}        
    end

    # GET /store_product_promotions/1
    def show
        render json: @store_product_promotion
    end

    # POST /store_product_promotions
    def create   
        authorize StoreProductPromotion     
        store_product_promotion = @store_product.store_product_promotions.build(permitted_attributes(StoreProductPromotion))

        if store_product_promotion.save
            KioskProduct.where(:store_product_id => store_product_promotion.store_product_id).touch_all
            StoreProduct.where(:id => store_product_promotion.store_product_id).touch_all
            store_product_promotion.store_product.update!(has_promotion: true)
            render json: store_product_promotion, status: :created
        else
            errors = store_product_promotion.errors.as_json
            render json: { errors: errors }, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /store_product_promotions/1
    def update
        authorize StoreProductPromotion     
        if @store_product_promotion.update(permitted_attributes(@store_product_promotion))
            KioskProduct.where(:store_product_id => @store_product_promotion.store_product_id).touch_all
            StoreProduct.where(:id => @store_product_promotion.store_product_id).touch_all
            render json: @store_product_promotion
        else
            errors = @store_product_promotion.errors.as_json
            render json: { errors: errors }, status: :unprocessable_entity
        end
    end

    # DELETE /store_product_promotions/1
    def destroy
        authorize StoreProductPromotion     

        KioskProduct.where(:store_product_id => @store_product_promotion.store_product_id).touch_all
        StoreProduct.where(:id => @store_product_promotion.store_product_id).touch_all
        @store_product_promotion.store_product.update!(has_promotion: false)

        @store_product_promotion.destroy
        render json: { message: "DELETED" }
    end

    def find_store
        @store = policy_scope(Store).find(params[:store_id])
    end

    def find_store_product
        @store_product = policy_scope(StoreProduct).find(params[:store_product_id])
    end

    def find_store_product_promotion
        @store_product_promotion = policy_scope(StoreProductPromotion).find(params[:id])
    end

    def search_includes
        [
          'store_product.product_variant.product',
          'store_product.store_category',        
        ]
      end
end
