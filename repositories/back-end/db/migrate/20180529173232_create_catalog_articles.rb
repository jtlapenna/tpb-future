class CreateCatalogArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :catalog_articles do |t|
      t.belongs_to :article, foreign_key: true
      t.belongs_to :catalog, foreign_key: true

      t.timestamps
    end
  end
end
