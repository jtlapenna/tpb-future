class RenameCatalogProductIdToStoreProduct < ActiveRecord::Migration[5.2]
  def change
    rename_column :catalog_articles_store_products, :catalog_product_id, :store_product_id
  end
end
