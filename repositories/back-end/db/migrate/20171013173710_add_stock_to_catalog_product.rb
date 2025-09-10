class AddStockToCatalogProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_products, :stock, :integer, default: 0, null: false
  end
end
