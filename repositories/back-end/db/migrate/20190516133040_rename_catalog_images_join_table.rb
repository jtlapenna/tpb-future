class RenameCatalogImagesJoinTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalog_products_images, :images_store_products
  end
end
