class AddThumbImageToCatalogProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_products, :thumb_image_id, :bigint
    add_foreign_key :catalog_products, :images, column: :thumb_image_id
  end
end
