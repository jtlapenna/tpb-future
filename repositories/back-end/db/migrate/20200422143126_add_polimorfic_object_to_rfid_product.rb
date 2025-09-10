class AddPolimorficObjectToRfidProduct < ActiveRecord::Migration[6.0]
  def change
    add_reference :rfid_products, :rfid_entity, polymorphic: true, null: true
  end
end