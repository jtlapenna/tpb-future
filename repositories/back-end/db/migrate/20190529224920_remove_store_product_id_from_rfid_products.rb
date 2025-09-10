class RemoveStoreProductIdFromRfidProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :rfid_products, :store_product_id
    remove_column :rfid_products, :store_id
  end
end
