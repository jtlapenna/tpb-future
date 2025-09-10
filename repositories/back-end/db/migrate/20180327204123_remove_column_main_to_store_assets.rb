class RemoveColumnMainToStoreAssets < ActiveRecord::Migration[5.1]
  def change
    remove_column :store_assets, :main, :string
  end
end
