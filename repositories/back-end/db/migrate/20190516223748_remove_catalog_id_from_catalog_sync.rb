class RemoveCatalogIdFromCatalogSync < ActiveRecord::Migration[5.2]
  def change
    remove_column :catalog_syncs, :catalog_id
  end
end
