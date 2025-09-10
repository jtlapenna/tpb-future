class AddRfidToCatalogProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_products, :rfid, :string
  end
end
