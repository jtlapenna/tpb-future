class AddCodeToStoreAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :store_assets, :code, :string
  end
end
