class AddPrimaryImageToCatalogProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_products, :primary_image_id, :bigint
    add_foreign_key :catalog_products, :images, column: :primary_image_id
  end
end
