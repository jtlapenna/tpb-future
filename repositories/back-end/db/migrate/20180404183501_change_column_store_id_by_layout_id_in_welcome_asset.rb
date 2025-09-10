class ChangeColumnStoreIdByLayoutIdInWelcomeAsset < ActiveRecord::Migration[5.1]
  def change
    remove_column :welcome_assets, :store_id, :integer
    add_column :welcome_assets, :store_layout_id, :integer

    add_index :welcome_assets, [:store_layout_id]
    add_foreign_key "welcome_assets", "store_layouts"
  end
end
