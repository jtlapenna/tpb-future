class UpdateRfidProductData < ActiveRecord::Migration[6.0]
  def change
    RfidProduct.update_all("rfid_entity_id = kiosk_product_id, rfid_entity_type = 'KioskProduct'")
    remove_column :rfid_products, :kiosk_product_id
  end
end