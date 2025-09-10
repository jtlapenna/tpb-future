class Api::V1::BrandsController < Api::V1::ApplicationController
  include Paged
  include Sortable

  def index
    brands = kiosk.brands
                  .select('brands.*, kiosk_products_count')
                  .includes(:logo)
                  .page(page)
                  .per(page_size)
                  .order(order_fields)

    render json: brands, root: 'brands',
           each_serializer: Api::V1::BrandSerializer,
           scope: kiosk,
           meta: pagination_dict(brands)
  end
end
