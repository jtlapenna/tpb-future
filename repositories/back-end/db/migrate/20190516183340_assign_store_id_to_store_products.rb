class AssignStoreIdToStoreProducts < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE store_products
        SET store_id = (
          SELECT store_id FROM store_categories
          WHERE store_categories.id = store_products.store_category_id
        )
      SQL
    )
  end

  def down
    raise "Not rollbackeable"
  end
end
