class AssignStoreIdToStoreArticles < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE store_articles
        SET store_id = (
          SELECT store_id FROM catalogs
          WHERE catalogs.id = store_articles.catalog_id
        )
      SQL
    )
  end
end
