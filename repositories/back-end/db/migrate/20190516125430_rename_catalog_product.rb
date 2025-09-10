class RenameCatalogProduct < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalog_products, :store_products
  end
end
