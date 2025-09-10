class AddFeaturedToCatalogProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :catalog_products, :featured, :boolean, default: false
  end
end
