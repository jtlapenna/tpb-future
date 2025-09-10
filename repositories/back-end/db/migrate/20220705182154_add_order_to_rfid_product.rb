class AddOrderToRfidProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :rfid_products, :order, :integer, null: true
  end
end
