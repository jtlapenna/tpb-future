class AddStoreIdToRfidProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :rfid_products, :store, foreign_key: true
  end
end
