class RenameCatalogProductIdJoinTableColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :images_store_products, :catalog_product_id, :store_product_id
  end
end
