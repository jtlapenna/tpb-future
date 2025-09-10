class RenameCatalogIdOnCustomerOrder < ActiveRecord::Migration[5.2]
  def change
    rename_column :customer_orders, :catalog_id, :kiosk_id
  end
end
