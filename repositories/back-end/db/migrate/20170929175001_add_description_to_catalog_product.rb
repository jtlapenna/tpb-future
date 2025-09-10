class AddDescriptionToCatalogProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_products, :description, :string
  end
end
