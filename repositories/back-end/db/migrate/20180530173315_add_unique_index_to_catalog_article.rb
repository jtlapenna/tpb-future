class AddUniqueIndexToCatalogArticle < ActiveRecord::Migration[5.1]
  def change
    add_index :catalog_articles, [:catalog_id, :article_id], unique: true
  end
end
