class CreatePictureInPictures < ActiveRecord::Migration[5.1]
  def change
    create_table :picture_in_pictures do |t|
      t.integer :layout_position_id
      t.integer :store_asset_id
      t.string :link

      t.timestamps
    end
  end
end
