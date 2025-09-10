class AddVideoImageBackgroundAssetToKioskLayouts < ActiveRecord::Migration[6.0]
  def change
    add_reference :kiosk_layouts, :video_image_background_asset, foreign_key: true
  end
end