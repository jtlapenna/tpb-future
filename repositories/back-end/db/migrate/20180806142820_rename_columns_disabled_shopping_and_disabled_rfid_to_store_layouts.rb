class RenameColumnsDisabledShoppingAndDisabledRfidToStoreLayouts < ActiveRecord::Migration[5.1]
  def change
    rename_column :store_layouts, :disabled_rfid, :rfid_disabled
    rename_column :store_layouts, :disabled_shopping, :shopping_disabled
  end
end
