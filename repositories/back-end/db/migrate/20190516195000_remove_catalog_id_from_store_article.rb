class RemoveCatalogIdFromStoreArticle < ActiveRecord::Migration[5.2]
  def change
    remove_column :store_articles, :catalog_id
  end
end
