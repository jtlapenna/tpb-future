class AddRfidSortingToKiosk < ActiveRecord::Migration[6.0]
  def change
    add_column :kiosks, :rfid_sorting, :string, :default => 0
  end
end
