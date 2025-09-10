class DeleteColumnStoreLayoutIdFromWelcomeAssetAndAddToWelcomeAssetIdToStoreLayout < ActiveRecord::Migration[5.1]
  def change
    remove_column :welcome_assets, :store_layout_id, :integer
    add_column :store_layouts, :welcome_asset_id, :integer

    add_index :store_layouts, [:welcome_asset_id]
    add_foreign_key "store_layouts", "welcome_assets"
  end
end
