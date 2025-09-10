class AddRfidBehaviorToRfidProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :kiosks, :rfid_behavior, :string, :default => 0
  end
end
