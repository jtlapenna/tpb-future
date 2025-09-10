class RenameStoreLayouts < ActiveRecord::Migration[5.2]
  def change
    rename_table :store_layouts, :kiosk_layouts
  end
end
