class RenameCatalogCategory < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalog_categories, :store_categories
  end
end
