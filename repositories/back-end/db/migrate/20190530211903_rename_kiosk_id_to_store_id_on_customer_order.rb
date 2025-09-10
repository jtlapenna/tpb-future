class RenameKioskIdToStoreIdOnCustomerOrder < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :customer_orders, :kiosks
    rename_column :customer_orders, :kiosk_id, :store_id
    add_foreign_key :customer_orders, :stores
  end
end
