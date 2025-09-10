class AddKioskProductToRfidProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :rfid_products, :kiosk_product, foreign_key: true
  end
end
