class Api::V1::StoresController < Api::V1::ApplicationController
  def show
    render json: current_store, include: [
      'logo',
      'settings.background_media',
      'layout.store_assets.pictures_in_pictures.asset',
      'layout.store_assets.dots.asset',
      'layout.welcome_asset.asset',
      'layout.video_image_background_asset.asset',
      'layout.store_assets.asset',
      'layout.navigation.items.asset',
      'layout.store_categories'
    ]
  end
end
