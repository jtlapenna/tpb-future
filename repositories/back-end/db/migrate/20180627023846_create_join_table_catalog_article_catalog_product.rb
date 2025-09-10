class CreateJoinTableCatalogArticleCatalogProduct < ActiveRecord::Migration[5.1]
  def change
    create_join_table :catalog_articles, :catalog_products do |t|
      t.index [:catalog_article_id, :catalog_product_id], name: 'catalog_article_product_join_table'
      t.index [:catalog_product_id, :catalog_article_id], name: 'product_catalog_article_join_table'
    end

    add_foreign_key :catalog_articles_products, :catalog_articles
    add_foreign_key :catalog_articles_products, :catalog_products
  end
end
