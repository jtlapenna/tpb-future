class Api::V1::AdBannerLocationsController < ApplicationController
  include Paged
  include Sortable
  include Searchable

  before_action :find_location, only: %i[update destroy show]
  def index
    q = params[:q] != nil ? "%" + params[:q] + "%" : "%";
    @locations = AdBannerLocation.all.page(page)
                .per(page_size)
                .order(order_fields)
                .where('ad_banner_locations.text ILIKE ?', q)
    render json: @locations,
           meta: pagination_dict(@locations),
           each_serializer: Api::V1::AdBannerLocationSerializer
  end

  def show
    render json: @location
  end

  def create
    @location = AdBannerLocation.new(location_params)
    if @location.save
      render json: @location
    else
      render json: {error: 'Unable to create ad banner location', details: @location.errors.as_json}, status: 400
    end
  end

  def update
    if @location && @location.update(location_params)
        render json: @location
    else
        render json: {error: 'Undable to update ad location.', details: @location.errors.as_json}, status: :unprocessable_entity
    end
  end


  private

  def location_params
    params.require(:ad_banner_location).permit(:text)
  end

  def find_location
    @location = AdBannerLocation.find(params[:id])
  end
end
