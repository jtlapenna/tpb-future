class AddHomeScreenTitleToKioskLayouts < ActiveRecord::Migration[6.0]
  def change
    add_column :kiosk_layouts, :home_screen_title, :string
  end
end
