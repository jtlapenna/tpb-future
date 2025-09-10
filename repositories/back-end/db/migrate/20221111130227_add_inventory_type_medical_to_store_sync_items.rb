class AddInventoryTypeMedicalToStoreSyncItems < ActiveRecord::Migration[6.0]
  def change
    add_column :store_sync_items, :inventory_type_medical, :boolean, default: false
  end
end
