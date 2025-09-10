class ChangeDefaultRfidOrderValue < ActiveRecord::Migration[6.0]
  def change
    change_column :rfid_products, :order, :integer, default: 0
  end
end
