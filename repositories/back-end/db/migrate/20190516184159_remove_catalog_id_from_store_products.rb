class RemoveCatalogIdFromStoreProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :store_products, :catalog_id
  end
end
