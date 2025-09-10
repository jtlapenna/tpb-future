class RemoveCatalogIdFromStorePrice < ActiveRecord::Migration[5.2]
  def change
    remove_column :store_prices, :catalog_id
  end
end
