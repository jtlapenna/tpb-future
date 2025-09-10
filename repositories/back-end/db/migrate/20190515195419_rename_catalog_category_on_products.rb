class RenameCatalogCategoryOnProducts < ActiveRecord::Migration[5.2]
  def change
    rename_column :catalog_products, :catalog_category_id, :store_category_id
  end
end
