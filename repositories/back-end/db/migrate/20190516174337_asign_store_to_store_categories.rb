class AsignStoreToStoreCategories < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE store_categories set store_id = (
          SELECT store_id FROM catalogs
          WHERE catalogs.id = store_categories.catalog_id
        )
      SQL
    )
  end

  def down
    raise "Not rollbackeable"
  end
end
