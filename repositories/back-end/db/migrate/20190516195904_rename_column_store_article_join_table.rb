class RenameColumnStoreArticleJoinTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :store_articles_products, :catalog_article_id, :store_article_id
  end
end
