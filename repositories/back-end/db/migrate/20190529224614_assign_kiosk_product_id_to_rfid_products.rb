class AssignKioskProductIdToRfidProducts < ActiveRecord::Migration[5.2]
  def change
    execute(
      <<-SQL
        UPDATE rfid_products
        SET kiosk_product_id = (
          SELECT id FROM kiosk_products
          WHERE store_product_id = rfid_products.store_product_id
          LIMIT 1
        )
      SQL
    )
  end
end
