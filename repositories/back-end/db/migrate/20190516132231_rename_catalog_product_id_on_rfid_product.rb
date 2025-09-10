class RenameCatalogProductIdOnRfidProduct < ActiveRecord::Migration[5.2]
  def change
    rename_column :rfid_products, :catalog_product_id, :store_product_id
  end
end
