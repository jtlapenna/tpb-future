class AddKioskIdToRfidProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :rfid_products, :kiosk, foreign_key: true
  end
end
