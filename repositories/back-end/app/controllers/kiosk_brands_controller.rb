class KioskBrandsController < ApplicationController
    include Paged
    include Sortable

    before_action :find_kiosk

    def index
        filter = params[:q] != nil ? "%" + params[:q] + "%" : "%"; 
        if(params[:q] != nil) 
            brands = @kiosk.brands
                        .select('brands.*, kiosk_products_count')
                        .where('brands.name ILIKE ?', filter)
                        .includes(:logo)
                        .page(page)
                        .per(page_size)
                        .order(order_fields)
        else
            brands = @kiosk.brands
            .select('brands.*, kiosk_products_count')
            .includes(:logo)
            .page(page)
            .per(page_size)
            .order(order_fields)
        end

        render json: brands, root: 'brands',
            each_serializer: Api::V1::BrandSerializer,
            scope: @kiosk,
            meta: pagination_dict(brands)
    end

    def find_kiosk
        @kiosk = policy_scope(Kiosk).find(params[:kiosk_id])
    end
end
