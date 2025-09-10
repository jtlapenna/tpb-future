class AddNavUiToKioskLayouts < ActiveRecord::Migration[6.0]
  def change
    add_column :kiosk_layouts, :nav_ui, :integer, default: 0
  end
end
