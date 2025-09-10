class AdConfigsController < ApplicationController
    include Paged

    before_action :find_kiosk
    before_action :find_ad_config, only: %i[show update destroy]

    def index
        # authorize AdConfig
        
        searchBy = params[:filter] != nil ? "%" + params[:filter] + "%" : "%";        
        ad_configs = @kiosk.ad_configs.page(page).per(page_size).where('name ILIKE ?', searchBy)        

        render json: ad_configs, each_serializer: AdConfigSerializer,  meta: pagination_dict(ad_configs)
    end

    def create   
        # authorize AdConfig
        ad_config = @kiosk.ad_configs.build(permitted_attributes(AdConfig))

        if ad_config.save            
            render json: ad_config, status: :created
        else
            errors = ad_config.errors.as_json
            render json: { errors: errors }, status: :unprocessable_entity
        end
    end
    
    def show
        render json: @ad_config
    end

    def update
        # authorize AdConfig
        
        if @ad_config.update(permitted_attributes(@ad_config))            
            render json: @ad_config
        else
            errors = @ad_config.errors.as_json
            render json: { errors: errors }, status: :unprocessable_entity
        end
    end
    
    def destroy
        # authorize AdConfig
        
        @ad_config.destroy
        render json: { message: "DELETED" }
    end

    def find_kiosk
        @kiosk = policy_scope(Kiosk).find(params[:kiosk_id])
    end

    def find_ad_config
        @ad_config = policy_scope(AdConfig).find(params[:id])
    end
end
