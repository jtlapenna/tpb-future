class RenameCatalogSyncIdOnCatalogSyncItem < ActiveRecord::Migration[5.2]
  def change
    rename_column :catalog_sync_items, :catalog_sync_id, :store_sync_id
  end
end
