class AddDisabledRfidDisabledShoppingToStoreLayouts < ActiveRecord::Migration[5.1]
  def change
    add_column :store_layouts, :disabled_rfid, :boolean, default: false
    add_column :store_layouts, :disabled_shopping, :boolean, default: false
  end
end
