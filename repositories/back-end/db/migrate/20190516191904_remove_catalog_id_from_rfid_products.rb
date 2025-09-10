class RemoveCatalogIdFromRfidProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :rfid_products, :catalog_id
  end
end
