class ChangeColumnStoreIdByLayoutIdInStoreAssets < ActiveRecord::Migration[5.1]
  def change
    remove_column :store_assets, :store_id, :integer
    add_column :store_assets, :store_layout_id, :integer

    add_index :store_assets, [:store_layout_id]
    add_foreign_key "store_assets", "store_layouts"
  end
end
