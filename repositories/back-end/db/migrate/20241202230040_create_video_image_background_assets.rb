class CreateVideoImageBackgroundAssets < ActiveRecord::Migration[6.0]
  def change
    create_table :video_image_background_assets do |t|
      t.integer :asset_position_id

      t.timestamps
    end
  end
end