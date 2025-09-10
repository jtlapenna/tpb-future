class AddStateToCatalogSyncItem < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_sync_items, :status, :integer, default: 0
  end
end
