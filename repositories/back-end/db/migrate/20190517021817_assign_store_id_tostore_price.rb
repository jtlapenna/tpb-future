class AssignStoreIdTostorePrice < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE store_prices
        SET store_id = (
          SELECT store_id FROM catalogs
          WHERE catalogs.id = store_prices.catalog_id
        )
      SQL
    )
  end
end
