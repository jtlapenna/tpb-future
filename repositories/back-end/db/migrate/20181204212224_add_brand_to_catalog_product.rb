class AddBrandToCatalogProduct < ActiveRecord::Migration[5.2]
  def change
    add_reference :catalog_products, :brand, foreign_key: true
  end
end
