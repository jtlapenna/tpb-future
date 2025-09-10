class KioskLayoutsController < ApplicationController
  before_action :find_kiosk_layout, only: %i[show update]

  def update
    authorize @kiosk_layout
    if @kiosk_layout.update(permitted_attributes(@kiosk_layout))      
      params[:kiosk_layout][:store_categories].each do |store_category|
        @kiosk_layout.store_category_kiosk_layouts.where({ store_category_id: store_category[:id] }).first_or_create.update(order: store_category[:order])
      end
      @kiosk_layout.store_category_kiosk_layouts.where.not({ store_category_id: params[:kiosk_layout][:store_categories].map{|store_category| store_category[:id]} }).delete_all
      render json: @kiosk_layout, include: kiosk_layout_includes
    else
      errors = @kiosk_layout.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @kiosk_layout
    render json: @kiosk_layout, include: kiosk_layout_includes
  end

  private

  def find_kiosk_layout
    @kiosk_layout ||= policy_scope(KioskLayout).find_by(id: params[:id])
  end

  def kiosk_layout_includes
    [
      'kiosk',
      'kiosk_assets.asset_elements.asset',
      'welcome_asset.asset',
      'video_image_background_asset.asset',
      'kiosk_assets.asset',
      'navigation.items.asset',
      'store_category',
      'store_category_kiosk_layouts',
      'store_categories'
    ]
  end
end
