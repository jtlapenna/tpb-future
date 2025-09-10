class RenameStoreAsset < ActiveRecord::Migration[5.2]
  def change
    rename_table :store_assets, :kiosk_assets
  end
end
