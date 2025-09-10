class CreateAssetElements < ActiveRecord::Migration[5.1]
  def change
    create_table :asset_elements do |t|
      t.string :coord_x
      t.string :coord_y
      t.string :link
      t.string :store_asset_id
      t.string :element_type

      t.timestamps
    end
  end
end
