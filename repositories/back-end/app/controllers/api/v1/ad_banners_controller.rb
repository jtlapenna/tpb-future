class Api::V1::AdBannersController < ApplicationController
    include Paged
    include Sortable
    include Searchable

    before_action :find_store
    before_action :find_ad, only: %i[show update destroy]
    def index
        q = params[:q] != nil ? "%" + params[:q] + "%" : "%";
        @ads = @store.ad_banners.all
        @ads = @ads
            .page(page)
            .per(page_size)
            .order(order_fields)
            .where('ad_banners.text ILIKE ? or ad_banners.text IS NULL', q)            
        render  json: @ads,                
                meta: pagination_dict(@ads),
                each_serializer: Api::V1::AdBannerSerializer
    end

    def show
        render json: @ad, include: [            
            :ad_banner_location,
            :ad_banner_location_id,
            :advertisable,
            :advertisable_image,                        
        ]
    end

    def create
        @ad = @store.ad_banners.new(ad_params)
        if @ad.save
            render json: @ad, status: :created
        else            
            render json: {error: 'Unable to create ad.', detail: @ad.errors.as_json}, status: :unprocessable_entity
        end
    end

    def update
        if @ad
            @ad.update(ad_params)
            render json: @ad
        else
            render json: {error: 'Undable to update ad.', details: @ad.errors.as_json}, status: :unprocessable_entity
        end
    end

    def destroy
        if @ad
            @ad.destroy
            render status: 204
        else
            render json: {error: 'Undable to delete ad.'}, status: :unprocessable_entity
        end
    end

    private

    def find_ad
       @ad = @store.ad_banners.find(params[:id])
    end

    def find_store
        @store = policy_scope(Store).find(params[:store_id])        
    end

    def ad_params
        params.require(:ad_banner).permit(
            :ad_banner_location_id,
            :text,
            :callback_url,
            :store_id,
            :disabled,
            :advertisable_id,
            :advertisable_type,
            advertisable_image_attributes: %i[id url _destroy],
            images_attributes: %i[id url _destroy],
        )
    end
end
