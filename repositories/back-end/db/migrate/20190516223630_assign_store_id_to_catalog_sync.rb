class AssignStoreIdToCatalogSync < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE catalog_syncs
        SET store_id = (
          SELECT store_id FROM catalogs
          WHERE catalog_syncs.catalog_id = catalogs.id
        )
      SQL
    )
  end
end
