class MoveLayoutColumnFromStoreAssetToStore < ActiveRecord::Migration[5.1]
  def change
    remove_column :store_assets, :layout, :string
    add_column :stores, :layout, :string
  end
end
