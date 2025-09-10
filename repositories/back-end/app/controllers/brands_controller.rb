class BrandsController < ApplicationController
  include Paged
  include Sortable

  before_action :find_brand, only: %i[show update]

  def index
    authorize Brand

    q = params[:q]
    current_tab = params[:currentTab]
    kiosk_id = params[:kioskId]

    brands = policy_scope(Brand).includes(:logo)
    brands = brands.containing_text(q) if q.present?

    if current_tab && current_tab === "BrandAndStoreCategory" && kiosk_id
      store_id = Kiosk.find(kiosk_id).store_id
      brand_ids = StoreProduct
                 .where(store_id: store_id)
                 .group(:brand_id)
                 .having('COUNT(brand_id) > 1')
                 .pluck('brand_id')

      brands = brands.where(id: brand_ids)
    end

    brands = brands.page(page).per(page_size).order(order_fields)

    render json: brands, meta: pagination_dict(brands)
  end

  def create
    authorize Brand

    brand = Brand.new(permitted_attributes(Brand))

    if brand.save
      render json: brand, status: :created
    else
      errors = brand.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @brand

    if @brand.update(permitted_attributes(@brand))
      render json: @brand
    else
      errors = @brand.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @brand
    render json: @brand
  end
  def download_csv
    headers = ['ID', 'Name',"Logo", 'Store Count']
    csv_data = CSV.generate(headers: true) do |csv|
      csv << headers
      Brand.joins('LEFT JOIN assets ON assets.source_id = brands.id').where('assets.id is null')
                                                                  .sort_by{|a| a.store_count}
                                                                  .reverse.each do |m|
        csv << [m.id ,m.name,m.logo,m.store_count]
      end
    end
    send_data(
      csv_data,
      filename: 'myfile.csv', # suggests a filename for the browser to use.
      type: :csv,  # specifies a "text/csv" HTTP content type
    )
  end


  private

  def find_brand
    @brand ||= policy_scope(Brand).find(params[:id])
  end
end
