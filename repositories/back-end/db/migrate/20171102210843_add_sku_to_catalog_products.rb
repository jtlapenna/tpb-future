class AddSkuToCatalogProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_products, :sku, :string
  end
end
