class AssignKioskIdToRfidProducts < ActiveRecord::Migration[5.2]
  def change
    execute(
      <<-SQL
        UPDATE rfid_products
        SET kiosk_id = (
          SELECT id FROM kiosks
          WHERE store_id = rfid_products.store_id
          LIMIT 1
        )
      SQL
    )
  end
end
