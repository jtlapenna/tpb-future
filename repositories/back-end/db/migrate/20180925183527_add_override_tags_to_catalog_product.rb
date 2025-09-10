class AddOverrideTagsToCatalogProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_products, :override_tags, :boolean, default: false
  end
end
