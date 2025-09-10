class AddCatalogIdToCatalogProduct < ActiveRecord::Migration[5.1]
  def change
    add_reference :catalog_products, :catalog, foreign_key: true
  end
end
