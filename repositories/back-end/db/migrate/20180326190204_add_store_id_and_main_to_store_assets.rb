class AddStoreIdAndMainToStoreAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :store_assets, :store_id, :integer
    add_column :store_assets, :main, :boolean, default: false
  end
end
