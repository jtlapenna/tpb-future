class RenameCatalogSyncItem < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalog_sync_items, :store_sync_items
  end
end
