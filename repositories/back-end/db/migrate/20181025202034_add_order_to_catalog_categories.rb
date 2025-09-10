class AddOrderToCatalogCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_categories, :order, :integer
    add_index :catalog_categories, [:catalog_id, :order]
  end
end
