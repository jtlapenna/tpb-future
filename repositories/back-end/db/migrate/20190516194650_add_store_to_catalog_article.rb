class AddStoreToCatalogArticle < ActiveRecord::Migration[5.2]
  def change
    add_reference :store_articles, :store, foreign_key: true
  end
end
