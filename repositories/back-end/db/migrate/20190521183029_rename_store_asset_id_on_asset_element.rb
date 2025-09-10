class RenameStoreAssetIdOnAssetElement < ActiveRecord::Migration[5.2]
  def change
    rename_column :asset_elements, :store_asset_id, :kiosk_asset_id
  end
end
