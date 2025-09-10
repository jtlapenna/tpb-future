class RemoveCaatalogIdFromStoreCategory < ActiveRecord::Migration[5.2]
  def change
    remove_column :store_categories, :catalog_id
  end
end
