class RenameStoreArticlesProductsJoinTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalog_articles_store_products, :store_articles_products
  end
end
