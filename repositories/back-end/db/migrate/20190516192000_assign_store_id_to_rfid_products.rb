class AssignStoreIdToRfidProducts < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE rfid_products
        SET store_id = (
          SELECT store_id FROM store_products
          WHERE store_products.id = rfid_products.store_product_id
        )
      SQL
    )
  end

  def down
    raise "Not rollbackeable"
  end
end
