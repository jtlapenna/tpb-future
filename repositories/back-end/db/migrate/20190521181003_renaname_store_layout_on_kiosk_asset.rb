class RenanameStoreLayoutOnKioskAsset < ActiveRecord::Migration[5.2]
  def change
    rename_column :kiosk_assets, :store_layout_id, :kiosk_layout_id
  end
end
