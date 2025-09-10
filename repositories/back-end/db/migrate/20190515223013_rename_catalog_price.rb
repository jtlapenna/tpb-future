class RenameCatalogPrice < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalog_prices, :store_prices
  end
end
