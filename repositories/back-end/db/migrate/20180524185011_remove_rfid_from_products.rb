class RemoveRfidFromProducts < ActiveRecord::Migration[5.1]
  def change
    remove_column :catalog_products, :rfid
  end
end
