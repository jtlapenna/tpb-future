class AddScreenTypeToKioskLayout < ActiveRecord::Migration[5.2]
  def change
    add_column :kiosk_layouts, :screen_type, :integer, default: 1
  end
end
