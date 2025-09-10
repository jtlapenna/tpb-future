class AddStandSideToKioskLayout < ActiveRecord::Migration[5.2]
  def change
    add_column :kiosk_layouts, :stand_side, :integer, default: 0
  end
end
