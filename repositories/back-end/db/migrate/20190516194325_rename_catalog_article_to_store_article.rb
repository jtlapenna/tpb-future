class RenameCatalogArticleToStoreArticle < ActiveRecord::Migration[5.2]
  def change
    rename_table :catalog_articles, :store_articles
  end
end
