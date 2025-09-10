class RenameCatalogArticleProductsJoinTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalog_articles_products, :catalog_articles_store_products
  end
end
